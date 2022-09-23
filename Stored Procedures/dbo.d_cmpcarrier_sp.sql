SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_cmpcarrier_sp]
	@cartype1				varchar(6),
	@cartype2				varchar(6),
	@cartype3				varchar(6),
	@cartype4				varchar(6),
	@liabilitylimit			money,
	@cargolimit				money,
	@servicerating			varchar(6),
	@carid					varchar(8),
	@carname				varchar(64),
	@rateonly				char(1),
	@origin					varchar(58),
	@destination			varchar(58),
	@insurance				char(1),
	@w9						char(1),
	@contract				char(1),
	@history				char(1),	
	@domicile				int,
	@contact				varchar(30),
	@trcaccess				varchar(1000),
	@trlaccess				varchar(1000),
	@drvqual				varchar(1000),
	@carqual				varchar(1000),
	@stp_departure_dt		datetime,
 	@oradius				int, 	
	@dradius				int,
	@returntariffs			char(1),
	@branch					varchar(12),
	@ratesonly				char(1),
	@expdate				int
as
/*
ARGS:
@rateonly - used in ACS filter, "Show Rate" on the front end.  This will include extra results for carriers with state to state rates setup. 

@ratesonly - Used in the Planning Wksht filter views and appear on both External Equipment and Co. Carrier tabs.  "Only Carriers with Rates On File:" on the front end.
	Excludes carriers from the Co. Carrier result set unless they have rates on file.

@expdate  - expdate ini setting to determine if an expiration is coming soon

*/

set nocount on

create table #temp_filteredcarriers (
	fcr_carrier varchar(8), 
	fcr_car_city int,
	fcr_omiles_dom dec(12,6) null,
	fcr_dmiles_dom dec(12,6) null,
	fcr_dom_lat dec(12,6) null,
	fcr_dom_long dec(12,6) null,		
	fcr_domicile_state char(2),
	fcr_origdomicile char(1),
	fcr_destdomicile char(1),
 	keepfromfilter char(1)
	)

	-- blm	11.12.03

create table #temp1 (
	temp1_id int identity,
	trk_number int null,
	tar_number int null,
	tar_rate decimal(9,4) null,
	trk_carrier varchar(8) null,
	Crh_Total int null,
	Crh_OnTime int null,
	cht_itemcode varchar(6) null,
	cht_description varchar(30) null,
	Crh_percent	int null,
	Crh_AveFuel	money null,
	Crh_AveTotal	money null,
	Crh_AveAcc	money null,
	car_name	varchar(64) null,
	car_address1	Varchar(64) null,
	car_address2	Varchar(64) null,
	car_scac	Varchar(64) null,
	car_phone1	varchar(10) null,
	car_phone2	varchar(10) null,
	car_contact	varchar(25) null,
	car_phone3	varchar(10) null,
	car_email	varchar(128) null,
	car_currency	varchar(6) null, -- MRH 11/13/03
	cht_currunit	varchar(6) null, -- blm	11.12.03
	car_rating	varchar(12) NULL,
	exp_priority1 	int null,	-- BDH 33184 8/25/06
	exp_priority2 	int null,	-- BDH 33184 
	cty_nmstct	varchar(30) null,
    cartype1_t	varchar(20)	null,
    cartype2_t	varchar(20)	null,
    cartype3_t	varchar(20)	null,
    cartype4_t	varchar(20)	null,
	car_type1	varchar(6)	null,
	car_type2	varchar(6)	null,
	car_type3	varchar(6)	null,
	car_type4	varchar(6)	null,
	totalordersfiltered int null,
	ontimeordersfiltered int null,
	percentontimefiltered int null,
	keepfromfilter char(1) null,

	orig_domicile char(1) null,
	dest_domicile char(1) null,
	rateonfileorigin char(1) null,
	rateonfiledest char(1)null,
	haspaymenthist char(1) null,
	PayHistAtOrigin char(1) null,
	PayHistAtDest char(1) null,
	RatePaidAtOrigin char(1) null,
	RatePaidAtDest char(1) null,

	orig_domicile_comb char(1) null,
	dest_domicile_comb char(1) null,
	rateonfileorigin_comb char(1) null,
	rateonfiledest_comb char(1)null,
	haspaymenthist_comb char(1) null,
	PayHistAtOrigin_comb char(1) null,
	PayHistAtDest_comb char(1) null,
	RatePaidAtOrigin_comb char(1) null,
	RatePaidAtDest_comb char(1) null,

	MatchResult varchar (1000) null,
	CombinedMatchResult varchar (1000) null, 

test char(1) null,

	totalordersfiltered_comb	int			null,
	ontimeordersfiltered_comb	int			null,
	percentontimefiltered_comb	int			null,
	pri1expsoon					int			null,
	pri2expsoon					int			null,
    car_exp1date				datetime	null,
    car_exp2date				datetime	null,
	last_used	DATETIME NULL,
	total_billed	MONEY NULL,
	total_paid	MONEY NULL)


create table #temp3
	(Crh_Carrier varchar(8) null,
 	tar_number varchar(12) null,
	PayHistAtOrigin char(1) null,
	PayHistAtDest char(1) null,
	RatePaidAtOrigin char(1) null,
	RatePaidAtDest char(1) null)
	


create table #temp_carvalues (temp_id int identity, value varchar(8))
create table #temp_trcvalues (temp_id int identity, value varchar(8))
create table #temp_trlvalues (temp_id int identity, value varchar(8))
create table #temp_drvvalues (temp_id int identity, value varchar(8))

declare @temp_id int,
	@temp_value varchar (20),
	@count int,
	@current_car varchar(8),
	@ratematch decimal(9,4),
	@min_tar_number int,
	@dhmiles_dest int, 	
	@orig_lat dec(12,6),
	@orig_long dec(12,6),
	@dest_lat dec(12,6),
	@dest_long dec(12,6),
	@ls_ocity varchar(50),
	@ls_ostate varchar(20),
	@ete_commapos int,
	@ll_ocity int,
	@ls_dcity varchar(50),
	@ls_dstate varchar(20),	
	@ll_dcity int,
	@use_ocityonly char(1),
	@chunk char(2),
	@use_origzones varchar(100),
	@origzonestouse varchar(100),
	@use_origstates char(1),
	@origstatestouse varchar(100),
	@use_dcityonly char(1),
	@use_destzones varchar(100),
	@destzonestouse varchar(100),
	@use_deststates char(1),
	@deststatestouse varchar(100),
	@daysback int,
	@currentcar varchar(8),
	@hoursslack int,	
	@totalordersfiltered int,
	@ontimeordersfiltered int,
	@crh_percentfiltered int, 
	@workingOrigin varchar(58),
	@workingDestination varchar(58),
        @parse		VARCHAR(50),
        @pos		INTEGER,
	@where 		VARCHAR(1000),
	@sql		NVARCHAR(1000)
	

declare @carrierhistorydetail_ext table(
	ord_hdrnumber int,	
	tar_number varchar(12) null,
	pyd_rate money null,
	pyd_amount money null,
	ord_origincity int null,
	ord_originstate varchar(6) null,
	ord_destcity int null,
	ord_deststate varchar(6) null,
	Crh_Carrier 	varchar(8),
	origcity_lat dec(12,6) null,
	origcity_long dec(12,6) null,
	orig_miles_dist dec(12,6) null,
	destcity_lat dec(12,6) null,
	destcity_long dec(12,6) null,
	dest_miles_dist dec(12,6) null,
	useforOrigfilter char(1) null,
	useforDestfilter char(1) null,
	keepfromfilter char(1) null,
	ord_completiondate datetime null, 
	ord_dest_latestdate datetime null,
	orderontime char(1) null,
	pyd_number int null)


declare @temp_tars table(
	trk_carrier varchar(8) null,
	trk_number int null,
	tar_number int null,
	tar_rate decimal(9,4) null,
	trk_origincity int null,   
	trk_originstate varchar(6) null,
	trk_destcity int null,   
	trk_deststate varchar(6) null,
	rateonfileorigin char(1) null,
	rateonfiledest char(1) null,
	RatePaidAtOrigin char(1) null,
	RatePaidAtDest char(1) null)
	

set @origstatestouse = ''
set @origzonestouse = ''
set @deststatestouse = '' 
set @destzonestouse = ''
set @workingOrigin = @origin
set @workingDestination = @destination
if @history is null set @history = 'N'
if @dradius is null set @dradius = 0
if @dradius is null set @dradius = 0
--41213
if @carid = 'UNKNOWN' set @carid = '' 

set @stp_departure_dt = getdate()

-- Use this to add lat and long info to use the radius search later.
-- if @history = 'Y'
-- begin
	insert @CarrierHistoryDetail_ext (
	ord_hdrnumber,
	ord_origincity,
	ord_originstate,
	ord_destcity,
	ord_deststate,
	Crh_Carrier,
	useforOrigfilter,
	useforDestfilter,
	keepfromfilter,
	orderontime,
	ord_completiondate, 
	ord_dest_latestdate, 
    	--tar_number)
	pyd_number)
	
	select d.ord_hdrnumber,
	d.ord_origincity,
	d.ord_originstate,
	d.ord_destcity,
	d.ord_deststate,
	d.Crh_Carrier,
	'N', 'N', 'N', 'N',
	o.ord_completiondate,
	o.ord_dest_latestdate,

--PTS 42714
(select min (pyd_number) from paydetail with (nolock) inner join paytype on paydetail.pyt_itemcode = paytype.pyt_itemcode and paytype.pyt_basis = 'LGH'
where paydetail.asgn_type = 'CAR' and 
paydetail.asgn_id = d.crh_carrier AND
isnull(tar_tarriffnumber, 0) > 0 AND
paydetail.ord_hdrnumber = o.ord_hdrnumber)
--PTS 42714
 
--	(select min (pyd_number) from paydetail
--		where asgn_type = 'CAR' and 
--			  asgn_id = d.crh_carrier and
--			tar_tarriffnumber = 
--    		(select top 1 paydetail.tar_tarriffnumber --,pyd_rate,pyd_amount
--       			from paydetail, paytype
--      			where paydetail.ord_hdrnumber = o.ord_hdrnumber
--			and d.crh_carrier = paydetail.asgn_id
--			and paydetail.asgn_type = 'CAR'
--        		and paydetail.pyt_itemcode = paytype.pyt_itemcode
--        		and pyt_basis = 'LGH') )
	from CarrierHistoryDetail d, orderheader o
	where d.ord_hdrnumber = o.ord_hdrnumber


	update @CarrierHistoryDetail_ext
	set tar_number = pd.tar_tarriffnumber,
		pyd_rate = pd.pyd_rate,
		pyd_amount = pd.pyd_amount
	from paydetail pd, @CarrierHistoryDetail_ext ext
	where ext.pyd_number = pd.pyd_number 

-- end

-- Get first list of carriers for #temp_filteredcarriers.
insert #temp_filteredcarriers (fcr_carrier, fcr_car_city, fcr_dom_lat, fcr_dom_long, fcr_domicile_state, fcr_origdomicile, fcr_destdomicile, keepfromfilter)
select car_id , c.cty_code, cty_latitude, cty_longitude, cty_state, 'N', 'N', 'Y' 
from carrier c, city
where (isnull(@cartype1, '') = '' or @cartype1 = 'UNK' or  c.car_type1 = @cartype1)
 	and (isnull(@cartype2, '') = '' or @cartype2 = 'UNK' or  c.car_type2 = @cartype2)
 	and (isnull(@cartype3, '') = '' or @cartype3 = 'UNK' or  c.car_type3 = @cartype3)
 	and (isnull(@cartype4, '') = '' or @cartype4 = 'UNK' or  c.car_type4 = @cartype4)
 	and (isnull(@liabilitylimit, 0) = 0 or @liabilitylimit <= c.car_ins_liabilitylimits)
 	and (isnull(@cargolimit, 0) = 0 or @cargolimit <= c.car_ins_cargolimits)
 	and (isnull(@servicerating, '') = '' or @servicerating = 'UNK' or c.car_rating = @servicerating)
 	and (isnull(@carname, '') = '' or c.car_name like @carname + '%')	
	and ((@returntariffs = 'N' and isnull(@carid, '') = '' or (@returntariffs = 'N' and c.car_id like @carid + '%')) or (@returntariffs = 'Y' and c.car_id = @carid))
    and c.car_status <> 'OUT'  --PTS 43941
	

-- -- @returntariffs:  Y when returning multiple rows for a carrier, one for each applicable tariff, for the top of pmt hist float window.  We have a car_id at this point.
-- -- N when returning one row per carrier for the cmpcarrier tab on the planning worksheet.
  	and (isnull(@contact, '') = '' or c.car_contact like @contact + '%') 	
  	and (isnull(@insurance, '') = '' or car_ins_certificate = @insurance or @insurance = 'N')
  	and (isnull(@w9, '') = '' or car_ins_w9 = @w9 or @w9 = 'N')
  	and (isnull(@contract, '') = '' or car_ins_contract = @contract or @contract = 'N')
 	and c.cty_code = city.cty_code
  	and city.cty_code > 0
 	and (isnull(@branch, '') = '' or @branch = 'UNK' or @branch = 'UNKNOWN' or c.car_branch = @branch)


-- If len(@trlaccess) > 0 
--   BEGIN
-- 	delete #temp_filteredcarriers
-- 	where #temp_filteredcarriers.fcr_carrier NOT IN (select ta.ta_trailer
-- 													from trlaccessories ta
-- 													where ta.ta_source = 'CAR' AND
-- 															charindex(@trlaccess, ',' + ta.ta_type + ',') > 0 AND
-- 															ta.ta_expire_date >= @stp_departure_dt)
--   END
-- 
-- select * from trlaccessories
-- 
-- If len(@trcaccess) > 0 
--   BEGIN
-- 	delete #temp_filteredcarriers
-- 	where #temp_filteredcarriers.fcr_carrier NOT IN (select tca.tca_tractor
-- 													from tractoraccesories tca
-- 													where tca.tca_source = 'CAR' AND
-- 															charindex(@trcaccess, ',' + tca.tca_type + ',') > 0 AND
-- 															tca.tca_expire_date >= @stp_departure_dt)
--   END
-- 
-- If len(@drvqual) > 0 
--   BEGIN
-- 	delete #temp_filteredcarriers
-- 	where #temp_filteredcarriers.fcr_carrier NOT IN (select dq.drq_id
-- 													from driverqualifications dq
-- 													where dq.drq_source = 'CAR' AND
-- 															charindex(@drvqual, ',' + dq.drq_type + ',') > 0 AND
-- 															drq_expire_date >= @stp_departure_dt)
--   END
-- 
-- If len(@carqual) > 0 
--   BEGIN
-- 	delete #temp_filteredcarriers
-- 	where #temp_filteredcarriers.fcr_carrier NOT IN (select caq_id
-- 													from carrierqualifications cq
-- 													where 	charindex(@carqual, ',' + cq.caq_type + ',') > 0 AND
-- 															caq_expire_date >= @stp_departure_dt)
--   END

if len(@carqual) > 0
begin
   SET @where = NULL
   SET @carqual = @carqual + ','
   SET @pos = PATINDEX('%,%', @carqual)
   WHILE @pos > 0
   BEGIN
      SET @parse = LEFT(@carqual, @pos - 1)
      IF @where IS NULL
         SET @where = 'EXISTS(SELECT caq_type FROM carrierqualifications WHERE caq_id = car_id AND ' +
                      'ISNULL(caq_expire_flag, ''N'') <> ''Y'' AND ' +
                      'caq_expire_date >= GETDATE() AND ' + @parse + ')'
      ELSE
         SET @where = @where + ' AND ' + 'EXISTS(SELECT caq_type FROM carrierqualifications WHERE caq_id = car_id AND ' +
                      'ISNULL(caq_expire_flag, ''N'') <> ''Y'' AND ' +
                      'caq_expire_date >= GETDATE() AND ' + @parse + ')'

      SET @carqual = RIGHT(@carqual, Len(@carqual) - @pos)
      SET @pos = PATINDEX('%,%', @carqual)
   END

   SET @sql = 'DELETE #temp_filteredcarriers where fcr_carrier NOT IN (' +
              'SELECT car_id FROM carrier WHERE ' + @where + ')'
   
   EXECUTE sp_executesql @sql
end

if len(@trlaccess) > 0
begin
   SET @where = NULL
   SET @trlaccess = @trlaccess + ','
   SET @pos = PATINDEX('%,%', @trlaccess)
   WHILE @pos > 0
   BEGIN
      SET @parse = LEFT(@trlaccess, @pos - 1)
      IF @where IS NULL
         SET @where = 'EXISTS(SELECT ta_type FROM trlaccessories WHERE ta_trailer = car_id AND ' +
                      'ta_source = ''CAR'' AND ISNULL(ta_expire_flag, ''N'') <> ''Y'' AND ' +
                      'ta_expire_date >= GETDATE() AND ' + @parse + ')'
       ELSE
         SET @where = @where + ' AND ' + 'EXISTS(SELECT ta_type FROM trlaccessories WHERE ta_trailer = car_id AND ' +
                      'ta_source = ''CAR'' AND ISNULL(ta_expire_flag, ''N'') <> ''Y'' AND ' +
                      'ta_expire_date >= GETDATE() AND ' + @parse + ')'

      SET @trlaccess = RIGHT(@trlaccess, Len(@trlaccess) - @pos)
      SET @pos = PATINDEX('%,%', @trlaccess)
   END

   SET @sql = 'DELETE #temp_filteredcarriers where fcr_carrier NOT IN (' +
              'SELECT car_id FROM carrier WHERE ' + @where + ')'
   
   EXECUTE sp_executesql @sql
end

if len(@trcaccess) > 0
begin
   SET @where = NULL
   SET @trcaccess = @trcaccess + ','
   SET @pos = PATINDEX('%,%', @trcaccess)
   WHILE @pos > 0
   BEGIN
      SET @parse = LEFT(@trcaccess, @pos - 1)
      IF @where IS NULL
         SET @where = 'EXISTS(SELECT tca_type FROM tractoraccesories WHERE tca_tractor = car_id AND ' +
                      'tca_source = ''CAR'' AND ISNULL(tca_expire_flag, ''N'') <> ''Y'' AND ' +
                      'tca_expire_date >= GETDATE() AND ' + @parse + ')'
       ELSE
         SET @where = @where + ' AND ' + 'EXISTS(SELECT tca_type FROM tractoraccesories WHERE tca_tractor = car_id AND ' +
                      'tca_source = ''CAR'' AND ISNULL(tca_expire_flag, ''N'') <> ''Y'' AND ' +
                      'tca_expire_date >= GETDATE() AND ' + @parse + ')'

      SET @trcaccess = RIGHT(@trcaccess, Len(@trcaccess) - @pos)
      SET @pos = PATINDEX('%,%', @trcaccess)
   END

   SET @sql = 'DELETE #temp_filteredcarriers where fcr_carrier NOT IN (' +
              'SELECT car_id FROM carrier WHERE ' + @where + ')'
   
   EXECUTE sp_executesql @sql
end

if len(@drvqual) > 0
begin
   SET @where = NULL
   SET @drvqual = @drvqual + ','
   SET @pos = PATINDEX('%,%', @drvqual)
   WHILE @pos > 0
   BEGIN
      SET @parse = LEFT(@drvqual, @pos - 1)
      IF @where IS NULL
         SET @where = 'EXISTS(SELECT drq_type FROM driverqualifications WHERE drq_id = car_id AND ' +
                      'drq_source = ''CAR'' AND ISNULL(drq_expire_flag, ''N'') <> ''Y'' AND ' +
                      'drq_expire_date >= GETDATE() AND ' + @parse + ')'
      ELSE
         SET @where = @where + ' AND ' + 'EXISTS(SELECT drq_type FROM driverqualifications WHERE drq_id = car_id AND ' +
                      'drq_source = ''CAR'' AND ISNULL(drq_expire_flag, ''N'') <> ''Y'' AND ' +
                      'drq_expire_date >= GETDATE() AND ' + @parse + ')'

      SET @drvqual = RIGHT(@drvqual, Len(@drvqual) - @pos)
      SET @pos = PATINDEX('%,%', @drvqual)
   END

   SET @sql = 'DELETE #temp_filteredcarriers where fcr_carrier NOT IN (' +
              'SELECT car_id FROM carrier WHERE ' + @where + ')'

   EXECUTE sp_executesql @sql
end


/*-- Set #temp_filteredcarriers.keepfromfilter = N if they don't have accassories &/or qualifications
if len(@trcaccess) > 0 or len(@trlaccess) > 0 or len(@drvqual) > 0 or len(@carqual) > 0
begin
	select @current_car = min(fcr_carrier) from #temp_filteredcarriers 
	while len(@current_car) > 0 
	begin
		-- Check carrier qualifications	
		if len(@carqual) > 0 
		begin
			insert #temp_carvalues(value) select * from CSVStringsToTable_fn(@carqual)
			select @temp_id = min(temp_id) from #temp_carvalues
			While @temp_id > 0 
			begin				
				select @temp_value = value from #temp_carvalues where temp_id = @temp_id	
				select @count = count(*) from carrierqualifications
					where caq_id = @current_car and caq_type = @temp_value and isnull(caq_expire_flag, 'N') <> 'Y' and caq_expire_date > @stp_departure_dt
						
				if @count = 0 update #temp_filteredcarriers set keepfromfilter = 'N' where fcr_carrier = @current_car	
				select @temp_id = min(temp_id) from #temp_carvalues where temp_id > @temp_id
			end		
		end 
	
		-- Check tractor accessories
		if len(@trcaccess) > 0 
		begin
			insert #temp_trcvalues(value) select * from CSVStringsToTable_fn(@trcaccess)
			select @temp_id = min(temp_id) from #temp_trcvalues
			While @temp_id > 0 
			begin				
				select @temp_value = value from #temp_trcvalues where temp_id = @temp_id	
				select @count = count(*) from tractoraccesories
					where tca_tractor = @current_car and tca_type = @temp_value and isnull(tca_expire_flag, 'N') <> 'Y' and tca_expire_date > @stp_departure_dt and tca_source = 'CAR'
		
				if @count = 0 update #temp_filteredcarriers set keepfromfilter = 'N' where fcr_carrier = @current_car	
				select @temp_id = min(temp_id) from #temp_trcvalues where temp_id > @temp_id
			end
		end 
	
		-- Check trailer accessories
		if len(@trlaccess) > 0 
		begin
			insert #temp_trlvalues(value) select * from CSVStringsToTable_fn(@trlaccess)
			select @temp_id = min(temp_id) from #temp_trlvalues
			While @temp_id > 0 
			begin				
				select @temp_value = value from #temp_trlvalues where temp_id = @temp_id	
				select @count = count(*) from trlaccessories
					where ta_trailer = @current_car and ta_type = @temp_value and isnull(ta_expire_flag, 'N') <> 'Y' and ta_expire_date > @stp_departure_dt and ta_source = 'CAR'
		
				if @count = 0 update #temp_filteredcarriers set keepfromfilter = 'N' where fcr_carrier = @current_car	
				select @temp_id = min(temp_id) from #temp_trlvalues where temp_id > @temp_id
			end
		end 

		-- Check driver qualifications
		if len(@drvqual) > 0 
		begin
			insert #temp_drvvalues(value) select * from CSVStringsToTable_fn(@drvqual)
			select @temp_id = min(temp_id) from #temp_drvvalues
			While @temp_id > 0 
			begin				
				select @temp_value = value from #temp_drvvalues where temp_id = @temp_id	
				select @count = count(*) from driverqualifications
					where drq_driver = @current_car and drq_type = @temp_value and isnull(drq_expire_flag, 'N') <> 'Y' and drq_expire_date > @stp_departure_dt and drq_source = 'CAR'
		
				if @count = 0 update #temp_filteredcarriers set keepfromfilter = 'N' where fcr_carrier = @current_car	
				select @temp_id = min(temp_id) from #temp_drvvalues where temp_id > @temp_id
			end
		end 	
	
		select @current_car = min(fcr_carrier) from #temp_filteredcarriers where fcr_carrier > @current_car 
	end
end
*/
 

-- parse origin and destination args
-- if they have a city, state:
	-- update @CarrierHistoryDetail_ext with lat, long & distances.
	-- update #temp_filteredcarriers.fcr_origdomicile = Y if they are domiciled closely. 
-- else
	-- compile lists of states and zones.
if len(ltrim(rtrim(isnull(@workingOrigin, '')))) > 0
begin
	-- Parse Origin
	SELECT @ete_commapos = CHARINDEX(',', @workingOrigin)
	If @ete_commapos > 0 
	-- Has a comma, must be a city state
	BEGIN
		set @ls_ocity = RTRIM(LTRIM(LEFT(@workingOrigin, @ete_commapos - 1))) 
		set @ls_ostate = RTRIM(LTRIM(SUBSTRING(@workingOrigin, @ete_commapos + 1, 99))) 
		
		select  @ll_ocity = cty_code,
			@orig_lat = cty_latitude,
			@orig_long = cty_longitude 
		from city where cty_name = @ls_ocity and cty_state = @ls_ostate

		--if @history = 'Y'
		--begin
			--This is for the car hist radius.		
			update @CarrierHistoryDetail_ext 
			set origcity_lat  = (select cty_latitude from city where cty_code = ord_origincity),
				origcity_long = (select cty_longitude from city where cty_code = ord_origincity)
	
			--Compares the orig city in the pmt-hist vs the orig city in the proc arg.
			update @CarrierHistoryDetail_ext 
			set orig_miles_dist = dbo.tmw_airdistance_fn(@orig_lat, @orig_long, origcity_lat, origcity_long)
		--end

		--  Check to see if car's domicile is within radius.
		-- #temp_filteredcarriers keepfromfilter is set for domicile and quals.
		if @ll_ocity  > 0
		begin
			if isnull(@oradius, 0) > 0
			begin
				update #temp_filteredcarriers
					SET fcr_omiles_dom = dbo.tmw_airdistance_fn(@orig_lat, @orig_long, fcr_dom_lat, fcr_dom_long)
		
				update #temp_filteredcarriers
				--SET keepfromfilter = 'N' where fcr_omiles_dom > @oradius
				set fcr_origdomicile = 'Y' where fcr_omiles_dom <= @oradius
			end
			else
			begin
				update #temp_filteredcarriers
				--SET keepfromfilter = 'N' where fcr_car_city <> @ll_ocity
				set fcr_origdomicile = 'Y' where fcr_car_city = @ll_ocity
			end		
		end	
	END
	ELSE	-- see if we have origin states, zones, or both or see if the value is a city name with no state.
	begin	
		if exists (select 1 from city where cty_name = ltrim(rtrim(@workingOrigin)))
		   set @use_ocityonly = 'Y'
		else
		if len(rtrim(ltrim(@origin))) = 2 and rtrim(ltrim(@origin)) in (select tcz_state from transcore_zones)
		begin		
			set @use_origstates = 'Y'
			set @ls_ostate = rtrim(ltrim(@origin))
			set @origstatestouse = @ls_ostate
		end
		else
		begin
			if len(@workingOrigin) > 1 set @chunk = substring(@workingOrigin, 1, 2)
			While len(@chunk) > 0 
			begin	
				if substring(@chunk, 1, 1) = 'Z' and @chunk in (select distinct tcz_zone from transcore_zones)
				begin
					set @use_origzones = 'Y'
					set @origzonestouse = @origzonestouse + @chunk + ','
				end
				else
				begin
					if @chunk in (select distinct tcz_state from transcore_zones)
					begin
						set @use_origstates = 'Y'
						set @origstatestouse = @origstatestouse + @chunk + ','
					end
				end
			
				If (len(@workingOrigin) -2) >= 0
					set @workingOrigin = right(@workingOrigin, len(@workingOrigin) -2)
				if len(@workingOrigin) > 1 set @chunk = substring(@workingOrigin, 1, 2) else break
			end
		end
	end
end




if len(ltrim(rtrim(isnull(@workingDestination, '')))) > 0
begin
	-- Parse Destination
	SELECT @ete_commapos = CHARINDEX(',', @workingDestination)
	If @ete_commapos > 0 
	-- Has a comma, must be a city state
	BEGIN
		set @ls_dcity = RTRIM(LTRIM(LEFT(@workingDestination, @ete_commapos - 1))) 
		set @ls_dstate = RTRIM(LTRIM(SUBSTRING(@workingDestination, @ete_commapos + 1, 99))) 
		
		select  @ll_dcity = cty_code,
			@dest_lat = cty_latitude,
			@dest_long = cty_longitude 
		from city where cty_name = @ls_dcity and cty_state = @ls_dstate

		--if @history = 'Y'
		--begin
			update @CarrierHistoryDetail_ext 
			set destcity_lat = (select cty_latitude from city where cty_code = ord_destcity),
				destcity_long = (select cty_longitude from city where cty_code = ord_destcity)
	
			update @CarrierHistoryDetail_ext 
			set	dest_miles_dist = dbo.tmw_airdistance_fn(@dest_lat, @dest_long, destcity_lat, destcity_long)			
		--end

		if @ll_dcity  > 0
		begin
			if isnull(@dradius, 0) > 0
			begin
				update #temp_filteredcarriers
					SET fcr_dmiles_dom = dbo.tmw_airdistance_fn(@dest_lat, @dest_long, fcr_dom_lat, fcr_dom_long)
		
				update #temp_filteredcarriers
				--SET keepfromfilter = 'N' where fcr_dmiles_dom > @dradius
				set fcr_destdomicile = 'Y' where fcr_dmiles_dom <= @dradius
			end
			else
			begin
			update #temp_filteredcarriers
				--SET keepfromfilter = 'N' where fcr_car_city <> @ll_dcity
				set fcr_destdomicile = 'Y' where fcr_car_city = @ll_dcity
			end		
		end		
	END
	ELSE 	-- see if we have origin states, zones, or both or see if the value is a city name with no state.
	begin	
		if exists (select 1 from city where cty_name = ltrim(rtrim(@workingDestination)))
		   set @use_dcityonly = 'Y'
		else
		if len(rtrim(ltrim(@destination))) = 2 and rtrim(ltrim(@destination)) in (select tcz_state from transcore_zones)
		begin		
			set @use_deststates = 'Y'
			set @ls_dstate = rtrim(ltrim(@destination))
			set @deststatestouse = @ls_dstate
		end
		else
		begin
			if len(@workingDestination) > 1 set @chunk = substring(@workingDestination, 1, 2)
			While len(@chunk) > 0 
			begin	
				if substring(@chunk, 1, 1) = 'Z' and @chunk in (select distinct tcz_zone from transcore_zones)
				begin
					set @use_destzones = 'Y'
					set @destzonestouse = @destzonestouse + @chunk + ','
				end
				else
				begin
					if @chunk in (select distinct tcz_state from transcore_zones)
					begin
						set @use_deststates = 'Y'
						set @deststatestouse = @deststatestouse + @chunk + ','
					end
				end
			
				If (len(@workingDestination) -2) >= 0
					set @workingDestination = right(@workingDestination, len(@workingDestination) -2)
				if len(@workingDestination) > 1 set @chunk = substring(@workingDestination, 1, 2) else break
			end
		end
	end
end


-- if we are using states and or zones
	--update #temp_filteredcarriers with fcr_origdomicile = 'Y' and fcr_destdomicile = 'Y'
if @use_origstates = 'Y'
begin
	update #temp_filteredcarriers
	set fcr_origdomicile = 'Y'
	where fcr_domicile_state in (select * from CSVStringsToTable_fn(@origstatestouse))
end

if @use_origzones = 'Y'
begin
	update #temp_filteredcarriers
	set fcr_origdomicile = 'Y'
	where fcr_domicile_state in (select tcz_state from transcore_zones where tcz_zone in (select * from CSVStringsToTable_fn(@origzonestouse)))
end

 update #temp_filteredcarriers
 set fcr_origdomicile = 'Y'
 where fcr_car_city = @ll_ocity or fcr_omiles_dom <= @oradius

if @use_deststates = 'Y'
begin
	update #temp_filteredcarriers
	set fcr_destdomicile = 'Y'
	where fcr_domicile_state in (select * from CSVStringsToTable_fn(@deststatestouse))
end

if @use_destzones = 'Y'
begin
	update #temp_filteredcarriers
	set fcr_destdomicile = 'Y'
	where fcr_domicile_state in (select tcz_state from transcore_zones where tcz_zone in (select * from CSVStringsToTable_fn(@destzonestouse)))
end

 update #temp_filteredcarriers
 set fcr_destdomicile = 'Y'
 where fcr_car_city = @ll_dcity or fcr_dmiles_dom <= @dradius


 delete #temp_filteredcarriers where keepfromfilter = 'N' and fcr_origdomicile = 'N' and fcr_destdomicile = 'N'



-- check to see if trips in the @CarrierHistoryDetail_ext table meet the origin and destination arguments.
-- update @CarrierHistoryDetail_ext.set useforOrigfilter = 'Y' and set useforDestfilter = 'Y' 
	if len(@origin) = 0 or @origin is null 
	begin
		update @CarrierHistoryDetail_ext set useforOrigfilter = 'Y' 
	end
	else
	begin
		-- if a city, state origin.  See if the historydetail fits the bill.
		if @ll_ocity > 0 
		begin
			if @oradius > 0 
			begin
				update @CarrierHistoryDetail_ext 
				set useforOrigfilter = 'Y' 
				where orig_miles_dist <= @oradius			
			end
			else --no radius
			begin
				update @CarrierHistoryDetail_ext 
				set useforOrigfilter = 'Y' 
				where @ll_ocity = ord_origincity
			end		
		end
		
		-- if origin is states and or zones, ignore the radius.
		if @origstatestouse <> ''
		begin
			update @CarrierHistoryDetail_ext 
			set useforOrigfilter = 'Y' 
			where ord_originstate in (select * from CSVStringsToTable_fn(@origstatestouse))
		end
		
		if @origzonestouse <> ''
		begin
			update @CarrierHistoryDetail_ext 
			set useforOrigfilter = 'Y' 
			where ord_originstate in (select tcz_state from transcore_zones where tcz_zone in (select * from CSVStringsToTable_fn(@origzonestouse)))
		end
	end
	
	-- if a city, state destination.  See if the historydetail fits the bill.
	if len(@destination) = 0 or @destination is null
	begin
		update @CarrierHistoryDetail_ext set useforDestfilter = 'Y' 
	end
	else
	begin
		if @ll_dcity > 0 
		begin
			if @dradius > 0 
			begin
				update @CarrierHistoryDetail_ext 
				set useforDestfilter = 'Y' 
				where dest_miles_dist <= @dradius				
		
			end
			else --no radius
			begin
				update @CarrierHistoryDetail_ext 
				set useforDestfilter = 'Y' 
				where @ll_dcity = ord_destcity
			end		
		end
		
		-- if destination is states and or zones, ignore the radius.
		if @deststatestouse <> ''
		begin
			update @CarrierHistoryDetail_ext 
			set useforDestfilter = 'Y' 
			where ord_deststate in (select * from CSVStringsToTable_fn(@deststatestouse))
		end
		
		if @destzonestouse <> ''
		begin
			update @CarrierHistoryDetail_ext 
			set useforDestfilter = 'Y' 
			where ord_deststate in (select tcz_state from transcore_zones where tcz_zone in (select * from CSVStringsToTable_fn(@destzonestouse)))
		end
	end


-- get timeframe to see if the @CarrierHistoryDetail_ext order was ontime. 
select @Daysback = gi_integer1, @HoursSlack = gi_integer3 from generalinfo where gi_name = 'ACS-Days-Back'
select @daysback = isnull(@daysback, 90)
select @HoursSlack = isnull(@HoursSlack, 0)

update @CarrierHistoryDetail_ext
set orderontime = 'Y'
where ord_completiondate <= DateAdd(hh, @HoursSlack, ord_dest_latestdate)
-- 
-- -- At this point we have carriers that meet quals and domiciles ONLY in #temp_filteredcarriers, other have been deleted.
-- -- We have @CarrierHistoryDetail_ext with origfilter, destfilter, and ontime info.  All Keepfromfilters = N.


----------------------------------------------------------------------------**************************************


-- Add rateonfileorigin logic here.
-- insert for rates with a city and state
if @ll_ocity > 0
begin
	insert @temp_tars(trk_carrier, trk_number, tar_number, tar_rate, trk_origincity, trk_originstate, trk_destcity, trk_deststate, RateOnFileOrigin)
	select t.trk_carrier, t.trk_number, t.tar_number, h.tar_rate, trk_origincity, trk_originstate, trk_destcity, trk_deststate, 'Y'	
	from tariffkey t, tariffheaderstl h   	
	where t.tar_number = h.tar_number and isnull(trk_carrier, 'UNKNOWN') <> 'UNKNOWN' and
 		isnull(tar_rate, 0) > 0 and
		(t.trk_origincity = @ll_ocity or isnull(@ll_ocity, 0) = 0) and	
		(t.trk_originstate = @ls_ostate or isnull(@ls_ostate, '') = '') and 		
		--(t.trk_destcity = @ll_dcity or isnull(@ll_dcity, 0) = 0) and	
		--(t.trk_deststate = @ls_dstate or isnull(@ls_dstate, '') = '')		
		((@returntariffs = 'N' and isnull(@carid, '') = '' or (@returntariffs = 'N' and t.trk_carrier like @carid + '%')) or (@returntariffs = 'Y' and t.trk_carrier = @carid))
		
end		
if @ll_dcity > 0 
begin
	insert @temp_tars(trk_carrier, trk_number, tar_number, tar_rate, trk_origincity, trk_originstate, trk_destcity, trk_deststate, RateOnFileDest)
	select t.trk_carrier, t.trk_number, t.tar_number, h.tar_rate, trk_origincity, trk_originstate, trk_destcity, trk_deststate, 'Y'	
	from tariffkey t, tariffheaderstl h   	
	where t.tar_number = h.tar_number and isnull(trk_carrier, 'UNKNOWN') <> 'UNKNOWN' and
 		isnull(tar_rate, 0) > 0 and
		--(t.trk_origincity = @ll_ocity or isnull(@ll_ocity, 0) = 0) and	
		--(t.trk_originstate = @ls_ostate or isnull(@ls_ostate, '') = '') and 		
		(t.trk_destcity = @ll_dcity or isnull(@ll_dcity, 0) = 0) and	
		(t.trk_deststate = @ls_dstate or isnull(@ls_dstate, '') = '')		
		and ((@returntariffs = 'N' and isnull(@carid, '') = '' or (@returntariffs = 'N' and t.trk_carrier like @carid + '%')) or (@returntariffs = 'Y' and t.trk_carrier = @carid))
		
end
	-- insert rates with a state to state table
	-- origin state in the row
if @ls_ostate > '' 
begin
	insert @temp_tars(trk_carrier, trk_number, tar_number, tar_rate, trk_origincity, trk_originstate, trk_destcity, trk_deststate, RateOnFileOrigin)
	select  k.trk_carrier, k.trk_number, k.tar_number, stl.tra_rate, '', rc.trc_matchvalue, '', '', 'Y'
	from tariffheaderstl h, tariffkey k, tariffratestl stl, tariffrowcolumnstl rc   
	where h.tar_number = k.tar_number
		and h.tar_number = stl.tar_number
		and isnull(k.trk_carrier, 'UNKNOWN') <> 'UNKNOWN'
		and h.tar_rowbasis = 'OST'
		and rc.trc_number = stl.trc_number_row
		and stl.trc_number_row = (select trc_number from tariffrowcolumnstl where tar_number = h.tar_number and trc_rowcolumn = 'R' and trc_matchvalue = @ls_ostate)
	
	-- origin state in the column
	insert @temp_tars(trk_carrier, trk_number, tar_number, tar_rate, trk_origincity, trk_originstate, trk_destcity, trk_deststate, RateOnFileOrigin)
	select  k.trk_carrier, k.trk_number, k.tar_number, stl.tra_rate, '', rc.trc_matchvalue, '', '', 'Y'
	from tariffheaderstl h, tariffkey k, tariffratestl stl, tariffrowcolumnstl rc   
	where h.tar_number = k.tar_number
		and h.tar_number = stl.tar_number
		and isnull(k.trk_carrier, 'UNKNOWN') <> 'UNKNOWN'
		and h.tar_colbasis = 'OST'
		and rc.trc_number = stl.trc_number_col
		and stl.trc_number_col = (select trc_number from tariffrowcolumnstl where tar_number = h.tar_number and trc_rowcolumn = 'C' and trc_matchvalue = @ls_ostate)
end
if @ls_dstate > ''
begin	
	-- dest state in the row
	insert @temp_tars(trk_carrier, trk_number, tar_number, tar_rate, trk_origincity, trk_originstate, trk_destcity, trk_deststate, RateOnFileDest)
	select  k.trk_carrier, k.trk_number, k.tar_number, stl.tra_rate, '', '', '', rc.trc_matchvalue, 'Y'
	from tariffheaderstl h, tariffkey k, tariffratestl stl, tariffrowcolumnstl rc   
	where h.tar_number = k.tar_number
		and h.tar_number = stl.tar_number
		and isnull(k.trk_carrier, 'UNKNOWN') <> 'UNKNOWN'
		and h.tar_rowbasis = 'DST'
		and rc.trc_number = stl.trc_number_row
		and stl.trc_number_row = (select trc_number from tariffrowcolumnstl where tar_number = h.tar_number and trc_rowcolumn = 'R' and trc_matchvalue = @ls_dstate)
	
	-- dest state in the column
	insert @temp_tars(trk_carrier, trk_number, tar_number, tar_rate, trk_origincity, trk_originstate, trk_destcity, trk_deststate, RateOnFileDest)
	select  k.trk_carrier, k.trk_number, k.tar_number, stl.tra_rate, '', '', '', rc.trc_matchvalue, 'Y'
	from tariffheaderstl h, tariffkey k, tariffratestl stl, tariffrowcolumnstl rc   
	where h.tar_number = k.tar_number
		and h.tar_number = stl.tar_number
		and isnull(k.trk_carrier, 'UNKNOWN') <> 'UNKNOWN'
		and h.tar_colbasis = 'DST'
		and rc.trc_number = stl.trc_number_col
		and stl.trc_number_col = (select trc_number from tariffrowcolumnstl where tar_number = h.tar_number and trc_rowcolumn = 'C' and trc_matchvalue = @ls_dstate)
end


delete from @temp_tars where trk_carrier not in (select fcr_carrier from #temp_filteredcarriers)


-- See if any of the above rates have been paid
update @temp_tars set RatePaidAtOrigin = 'Y'
where RateOnFileOrigin = 'Y' and tar_number > 0 and tar_number in (select distinct tar_tarriffnumber from paydetail)

update @temp_tars set RatePaidAtDest = 'Y'
where RateOnFileDest = 'Y' and tar_number > 0 and tar_number in (select distinct tar_tarriffnumber from paydetail)

-- combine #temp and #filteredcars
insert @temp_tars (trk_carrier)
select fcr_carrier from #temp_filteredcarriers where fcr_carrier not in (select trk_carrier from @temp_tars)

insert into #temp1 
	(trk_number,
	tar_number,
	tar_rate,
	trk_carrier,
	Crh_Total,
	Crh_OnTime,
	cht_itemcode,
	cht_description,
	Crh_percent,
	Crh_AveFuel,
	Crh_AveTotal,
	Crh_AveAcc,
	car_name,
	car_address1,
	car_address2,
	car_scac,
	car_phone1,
	car_phone2,
	car_contact,
	car_phone3,
	car_email,
	car_currency,
	cht_currunit,
	car_rating,
	rateonfileorigin,
	rateonfiledest,
	MatchResult,
	combinedMatchresult , 
	RatePaidAtOrigin,
	RatePaidAtDest,
	test,
	cartype1_t,
	cartype2_t,
	cartype3_t,
	cartype4_t,
	car_type1,
	car_type2,
	car_type3,
	car_type4)


	select	trk_number, 
		t.tar_number, 
		th.tar_rate ,
		trk_carrier, 
		-- add isnulls to these carhistory values...BDH
		isnull(ch.crh_Total, 0) ,
		isnull(ch.crh_OnTime, 0) ,
		isnull(th.cht_itemcode, '') ,
		(select isnull(pyt_description, '') from paytype where pyt_itemcode = th.cht_itemcode),
		isnull(ch.Crh_percent, 0) ,
		isnull(ch.Crh_AveFuel, 0),
		isnull(ch.Crh_AveTotal, 0),
		isnull(ch.Crh_AveAcc, 0),
		-- Carrier information
		isnull(c.car_name, '') ,
		isnull(c.car_address1, '') ,
		isnull(c.car_address2, '') ,
		isnull(c.car_scac, '') ,
		isnull(c.car_Phone1, '') ,
		isnull(c.car_Phone2, ''),
		isnull(c.car_contact, '') ,
		isnull(c.car_phone3, '') ,
		isnull(c.car_email, ''),
		isnull(c.car_currency, '') , -- MRH 11/13/03
		'' cht_currunit,		-- blm	11.12.03
		(SELECT name FROM labelfile WHERE labeldefinition = 'CarrierServiceRating' and abbr = c.car_rating),
		rateonfileorigin,
		rateonfiledest,
		'', '', 
		RatePaidAtOrigin,
		RatePaidAtDest,
		'A',
		(select max(cartype1) from labelfile_headers) as 'cartype1_t',
		(select max(cartype2) from labelfile_headers) as 'cartype2_t',
		(select max(cartype3) from labelfile_headers) as 'cartype3_t',
		(select max(cartype4) from labelfile_headers) as 'cartype4_t',
		c.car_type1,
		c.car_type2,
		c.car_type3,
		c.car_type4
	from @temp_tars t inner join carrier c on t.trk_carrier = c.car_id
	left outer join carrierhistory ch on t.trk_carrier = ch.crh_carrier
	left outer join tariffheaderstl th on t.tar_number = th.tar_number
	where trk_carrier <> 'UNKNOWN'	
	 


-- -- Find only carriers that have lane, cities, states that match the criteria

-- Populate #temp3 with carids where:
 --16 combos of locations match and keepfromfilter (from = #temp_filteredcarriers) = Y
--if (@carid = '' or @carid = 'UNKNOWN' or @carid is null) and @history = 'Y'

--if  @history = 'Y'
--begin
	-- mark payment history records as worthy candidates. 
	update @carrierhistorydetail_ext
	set keepfromfilter = 'Y'
	where Crh_Carrier in (select fcr_carrier from #temp_filteredcarriers where keepfromfilter = 'Y')-- ? what about domiciles?

	-- 1
	if isnull(@ll_ocity, 0) > 0 and isnull(@ll_dcity, 0) = 0 and isnull(@ls_ostate, '') = '' and isnull(@ls_dstate, '') = ''
-- 		insert into #temp3 select Crh_Carrier from carrierhistory where
-- 		Crh_carrier in (
-- 			select Crh_Carrier from @carrierhistorydetail_ext where 			
-- 			useforOrigfilter = 'Y'  and keepfromfilter = 'Y'
-- 			group by Crh_Carrier)
		insert into #temp3(Crh_Carrier, tar_number, PayHistAtOrigin)    
		select distinct Crh_Carrier, tar_number, 'Y'
		from @carrierhistorydetail_ext 
		where useforOrigfilter = 'Y'  and keepfromfilter = 'Y'

	-- 2
	if isnull(@ll_ocity, 0) > 0 and isnull(@ll_dcity, 0) = 0 and isnull(@ls_ostate, '') = '' and isnull(@ls_dstate, '') > ''
		insert into #temp3(Crh_Carrier, tar_number, PayHistAtOrigin, PayHistAtDest)   
		select distinct Crh_Carrier, tar_number, 'Y', 'Y'
		from @carrierhistorydetail_ext 
		where useforOrigfilter = 'Y' and useforDestfilter = 'Y' and keepfromfilter = 'Y'

	-- 3
	if isnull(@ll_ocity, 0) > 0 and isnull(@ll_dcity, 0) = 0 and isnull(@ls_ostate, '') > '' and isnull(@ls_dstate, '') = ''
		insert into #temp3(Crh_Carrier, tar_number, PayHistAtOrigin)   
		select distinct Crh_Carrier, tar_number, 'Y'
		from @carrierhistorydetail_ext 
		where useforOrigfilter = 'Y'  and keepfromfilter = 'Y' 
		--group by Crh_Carrier


	-- 4
	if isnull(@ll_ocity, 0) > 0 and isnull(@ll_dcity, 0) = 0 and isnull(@ls_ostate, '') > '' and isnull(@ls_dstate, '') > ''
		insert into #temp3(Crh_Carrier, tar_number, PayHistAtOrigin, PayHistAtDest)   
		select distinct Crh_Carrier, tar_number, 'Y', 'Y'
		from @carrierhistorydetail_ext 
		where useforOrigfilter = 'Y' and useforDestfilter = 'Y' and keepfromfilter = 'Y'
	-- 5
	if isnull(@ll_ocity, 0) > 0 and isnull(@ll_dcity, 0) > 0 and isnull(@ls_ostate, '') = '' and isnull(@ls_dstate, '') = ''
		insert into #temp3(Crh_Carrier, tar_number, PayHistAtOrigin, PayHistAtDest)   
		select distinct Crh_Carrier, tar_number, 'Y', 'Y'
		from @carrierhistorydetail_ext 
		where useforOrigfilter = 'Y' and useforDestfilter = 'Y' and keepfromfilter = 'Y'

	-- 6
	if isnull(@ll_ocity, 0) > 0 and isnull(@ll_dcity, 0) > 0 and isnull(@ls_ostate, '') = '' and isnull(@ls_dstate, '') > ''
		insert into #temp3(Crh_Carrier, tar_number, PayHistAtOrigin)   
		select distinct Crh_Carrier, tar_number, 'Y'
		from @carrierhistorydetail_ext 
		where useforOrigfilter = 'Y' and useforDestfilter = 'Y' and keepfromfilter = 'Y'

	-- 7
	if isnull(@ll_ocity, 0) > 0 and isnull(@ll_dcity, 0) > 0 and isnull(@ls_ostate, '') > '' and isnull(@ls_dstate, '') = ''
		insert into #temp3(Crh_Carrier, tar_number, PayHistAtOrigin, PayHistAtDest)   
		select distinct crh_Carrier, tar_number, 'Y', 'Y'
		from @carrierhistorydetail_ext 
		where useforOrigfilter = 'Y' and useforDestfilter = 'Y' and keepfromfilter = 'Y'

	-- 8
	if isnull(@ll_ocity, 0) > 0 and isnull(@ll_dcity, 0) > 0 and isnull(@ls_ostate, '') > '' and isnull(@ls_dstate, '') > ''
		insert into #temp3(Crh_Carrier, tar_number, PayHistAtOrigin, PayHistAtDest)   
		select distinct Crh_Carrier, tar_number, 'Y', 'Y'
		from @carrierhistorydetail_ext 
		where useforOrigfilter = 'Y' and useforDestfilter = 'Y' and keepfromfilter = 'Y'
	-- 9
	if isnull(@ll_ocity, 0) = 0 and isnull(@ll_dcity, 0) > 0 and isnull(@ls_ostate, '') = '' and isnull(@ls_dstate, '') = ''
		insert into #temp3(Crh_Carrier, tar_number,  PayHistAtDest)   
		select distinct Crh_Carrier, tar_number,  'Y'
		from @carrierhistorydetail_ext 
		where useforDestfilter = 'Y' and keepfromfilter = 'Y'

	-- 10
	if isnull(@ll_ocity, 0) = 0 and isnull(@ll_dcity, 0) > 0 and isnull(@ls_ostate, '') = '' and isnull(@ls_dstate, '') > ''
		insert into #temp3(Crh_Carrier, tar_number,  PayHistAtDest)   
		select distinct Crh_Carrier, tar_number,  'Y'
		from @carrierhistorydetail_ext 
		where useforDestfilter = 'Y' and keepfromfilter = 'Y'

	-- 11
	if isnull(@ll_ocity, 0) = 0 and isnull(@ll_dcity, 0) > 0 and isnull(@ls_ostate, '') > '' and isnull(@ls_dstate, '') = ''
		insert into #temp3(Crh_Carrier, tar_number, PayHistAtOrigin, PayHistAtDest)   
		select distinct Crh_Carrier, tar_number, 'Y', 'Y'
		from @carrierhistorydetail_ext 
		where useforOrigfilter = 'Y' and useforDestfilter = 'Y' and keepfromfilter = 'Y'

	-- 12
	if isnull(@ll_ocity, 0) = 0 and isnull(@ll_dcity, 0) > 0 and isnull(@ls_ostate, '') > '' and isnull(@ls_dstate, '') > ''
		insert into #temp3(Crh_Carrier, tar_number, PayHistAtOrigin, PayHistAtDest)   
		select distinct Crh_Carrier, tar_number, 'Y', 'Y'
		from @carrierhistorydetail_ext 
		where useforOrigfilter = 'Y' and useforDestfilter = 'Y' and keepfromfilter = 'Y'

	-- 13
	if isnull(@ll_ocity, 0) = 0 and isnull(@ll_dcity, 0) = 0 and isnull(@ls_ostate, '') = '' and isnull(@ls_dstate, '') = ''
		insert into #temp3(Crh_Carrier, tar_number)   
		select distinct Crh_Carrier, tar_number
		from @carrierhistorydetail_ext 
		where keepfromfilter = 'Y'

	-- 14
	if isnull(@ll_ocity, 0) = 0 and isnull(@ll_dcity, 0) = 0 and isnull(@ls_ostate, '') = '' and isnull(@ls_dstate, '') > ''
		insert into #temp3(Crh_Carrier, tar_number, PayHistAtDest)   
		select distinct Crh_Carrier, tar_number, 'Y'
		from @carrierhistorydetail_ext 
		where useforDestfilter = 'Y' and keepfromfilter = 'Y'

	-- 15
	if isnull(@ll_ocity, 0) = 0 and isnull(@ll_dcity, 0) = 0 and isnull(@ls_ostate, '') > '' and isnull(@ls_dstate, '') = ''
		insert into #temp3(Crh_Carrier, tar_number, PayHistAtOrigin)   
		select distinct Crh_Carrier, tar_number, 'Y'
		from @carrierhistorydetail_ext 
		where useforOrigfilter = 'Y'  and keepfromfilter = 'Y'

	-- 16
	if isnull(@ll_ocity, 0) = 0 and isnull(@ll_dcity, 0) = 0 and isnull(@ls_ostate, '') > '' and isnull(@ls_dstate, '') > ''
		insert into #temp3(Crh_Carrier, tar_number, PayHistAtOrigin, PayHistAtDest)   
		select distinct Crh_Carrier, tar_number, 'Y', 'Y'
		from @carrierhistorydetail_ext 
		where useforOrigfilter = 'Y' and useforDestfilter = 'Y' and keepfromfilter = 'Y'


-- See if any of the above rates have been paid
update #temp3 set RatePaidAtOrigin = 'Y'
where PayHistAtOrigin = 'Y' and tar_number > 0 and tar_number in (select distinct tar_tarriffnumber from paydetail)

update #temp3 set RatePaidAtDest = 'Y'
where PayHistAtDest = 'Y' and tar_number > 0 and tar_number in (select distinct tar_tarriffnumber from paydetail)



--end
--else -- @History = N:  we need to get carriers into Temp3 without looking at pmthist.
-- begin
-- 	insert into #temp3 (crh_carrier) select fcr_carrier from #temp_filteredcarriers where fcr_origdomicile = 'Y' or fcr_destdomicile = 'Y' or keepfromfilter = 'Y'					
--end


--select * from #temp3

insert into #temp1
	(trk_number,
	tar_number,
	tar_rate,
	trk_carrier,
	Crh_Total,
	Crh_OnTime,
	cht_itemcode,
	cht_description,
	Crh_percent,
	Crh_AveFuel,
	Crh_AveTotal,
	Crh_AveAcc,
	car_name,
	car_address1,
	car_address2,
	car_scac,
	car_phone1,
	car_phone2,
	car_contact,
	car_phone3,
	car_email,
	car_currency,
	cht_currunit,
	car_rating,
	PayHistAtOrigin,
	PayHistAtDest,
	MatchResult,
	combinedMatchresult, 
	RatePaidAtOrigin,
	RatePaidAtDest,
	test,
	cartype1_t,
	cartype2_t,
	cartype3_t,
	cartype4_t,
	car_type1,
	car_type2,
	car_type3,
	car_type4)

	select
	0,--trk_number,
	tar_number,--0,
	0,  --tar_rate,
	ch.Crh_Carrier ,
	ch.Crh_Total,
	ch.Crh_OnTime,
	'',
	'',
	ch.Crh_Percent,
	ch.Crh_AveFuel,
	ch.Crh_AveTotal,
	ch.Crh_AveAcc, 
	c.car_name,
	c.car_address1 ,
	c.car_address2,
	c.car_scac,
	c.car_Phone1,
	c.car_Phone2,
	c.car_contact,
	c.car_phone3, 
	c.car_email,
	c.car_currency, -- BLM 11/13/03
--	(select car_currency from carrier where car_id = #temp.trk_carrier), -- MRH 11/13/03
	'',
	(SELECT name FROM labelfile WHERE labeldefinition = 'CarrierServiceRating' and abbr = c.car_rating),
	PayHistAtOrigin,
	PayHistAtDest,
	'', '', 
	RatePaidAtOrigin,
	RatePaidAtDest,
	'B',
	(select max(cartype1) from labelfile_headers) as cartype1_t,
	(select max(cartype2) from labelfile_headers) as cartype2_t,
	(select max(cartype3) from labelfile_headers) as cartype3_t,
	(select max(cartype4) from labelfile_headers) as cartype4_t,
	c.car_type1,
	c.car_type2,
	c.car_type3,
	c.car_type4
	from #temp3 t inner join carrier c on t.crh_carrier = c.car_id
	inner join carrierhistory ch on t.crh_carrier = ch.crh_carrier



--select * from #temp1
if @history = 'Y'and (@ll_ocity = 0 and @ll_dcity = 0 and @ls_ostate  = '' and @ls_dstate > '')
begin		
	delete from #temp1 where trk_Carrier not in (select crh_carrier from @CarrierHistoryDetail_ext union select fcr_carrier from #temp_filteredcarriers where fcr_origdomicile = 'Y' or fcr_destdomicile = 'Y') 									
end


if @history = 'Y' and (@ll_ocity > 0 or @ll_dcity > 0 or @ls_ostate  > '' or @ls_dstate > '')
begin	
	delete from #temp1 where trk_Carrier not in (select crh_carrier from #temp3 union select trk_carrier  from @temp_tars union  select fcr_carrier from #temp_filteredcarriers where fcr_origdomicile = 'Y' or fcr_destdomicile = 'Y')
end


update #temp1 set tar_number = 0 where tar_number is null
update @CarrierHistoryDetail_ext set tar_number = 0 where tar_number is null


-- update #temp1 with the filtered totals for each carrier.
update #temp1 set totalordersfiltered = 	
	(select count(*) from @CarrierHistoryDetail_ext 
	where tar_number = #temp1.tar_number and crh_carrier = #temp1.trk_carrier and useforOrigfilter = 'Y' and useforDestfilter = 'Y'	)
from #temp1



--if isnull(@history, 'N') = 'Y'
--begin
	update #temp1  set totalordersfiltered_comb = 
	 	(select sum(totalordersfiltered) from #temp1 B
		where ((isnull(@origin, '') > '' and isnull(@destination, '') = '' and @history = 'Y' and  isnull(PayHistAtOrigin, '')  = 'Y')
		or (isnull(@origin, '') = '' and isnull(@destination, '') > '' and @history = 'Y' and  isnull(PayHistAtDest, '')  = 'Y')
		or (isnull(@origin, '') > '' and isnull(@destination, '') > '' and @history = 'Y' and  isnull(PayHistAtOrigin, '') = 'Y' and isnull(PayHistAtDest, '') = 'Y')
		or (isnull(@origin, '') = '' and isnull(@destination, '') = '' and @history = 'Y' and  isnull(haspaymenthist, '') = 'Y')

		or (isnull(@origin, '') > '' and isnull(@destination, '') = '' and isnull(@history, 'N') = 'N' and  
			(isnull(PayHistAtOrigin, '') = 'Y' or isnull(orig_domicile, '') = 'Y' or isnull(rateonfileorigin, '') = 'Y' or isnull(RatePaidAtOrigin, '') = 'Y'))

		or (isnull(@origin, '') = '' and isnull(@destination, '') > '' and isnull(@history, 'N') = 'N' and  
			(isnull(PayHistAtDest, '') = 'Y' or isnull(Dest_domicile, '') = 'Y' or isnull(rateonfiledest, '') = 'Y' or isnull(RatePaidAtDest, '') = 'Y'))

		or (isnull(@origin, '') > '' and isnull(@destination, '') > '' and isnull(@history, 'N') = 'N'   
			and (isnull(PayHistAtOrigin, '') = 'Y' or isnull(orig_domicile, '') = 'Y' or isnull(rateonfileorigin, '') = 'Y' or isnull(RatePaidAtOrigin, '') = 'Y') 
			and (isnull(PayHistAtDest, '') = 'Y' or isnull(dest_domicile, '') = 'Y' or isnull(rateonfiledest, '') = 'Y' or isnull(RatePaidAtdest, '') = 'Y')		)
		and
		((isnull(@origin, '') > '' and isnull(@destination, '') = '' and isnull(@ratesonly, '')  = 'Y' and isnull(RatePaidAtOrigin, '') = 'Y') 
		or (isnull(@origin, '') = '' and isnull(@destination, '') > '' and isnull(@ratesonly, '')  = 'Y' and isnull(RatePaidAtDest, '') = 'Y') 
		or (isnull(@origin, '') > '' and isnull(@destination, '') > '' and isnull(@ratesonly, '')  = 'Y' and isnull(RatePaidAtOrigin, '') = 'Y' and isnull(RatePaidAtDest, '') = 'Y') 
		or isnull(@ratesonly, 'N') in ('N', '')))	
		and #temp1.trk_carrier = B.trk_carrier)


-- on time filtered
update #temp1 set ontimeordersfiltered = 
	(select count(*) from @CarrierHistoryDetail_ext where tar_number = #temp1.tar_number and crh_carrier = #temp1.trk_carrier and useforOrigfilter = 'Y' and useforDestfilter = 'Y' and orderontime = 'Y')
from #temp1

--if isnull(@history, 'N') = 'Y'
--begin

	update #temp1 set ontimeordersfiltered_comb = 
		(select sum(ontimeordersfiltered) from #temp1 B
		where ((isnull(@origin, '') > '' and isnull(@destination, '') = '' and @history = 'Y' and  isnull(PayHistAtOrigin, '')  = 'Y')
		or (isnull(@origin, '') = '' and isnull(@destination, '') > '' and @history = 'Y' and  isnull(PayHistAtDest, '')  = 'Y')
		or (isnull(@origin, '') > '' and isnull(@destination, '') > '' and @history = 'Y' and  isnull(PayHistAtOrigin, '') = 'Y' and isnull(PayHistAtDest, '') = 'Y')
		or (isnull(@origin, '') = '' and isnull(@destination, '') = '' and @history = 'Y' and  isnull(haspaymenthist, '') = 'Y')

		or (isnull(@origin, '') > '' and isnull(@destination, '') = '' and isnull(@history, 'N') = 'N' and  
			(isnull(PayHistAtOrigin, '') = 'Y' or isnull(orig_domicile, '') = 'Y' or isnull(rateonfileorigin, '') = 'Y' or isnull(RatePaidAtOrigin, '') = 'Y'))

		or (isnull(@origin, '') = '' and isnull(@destination, '') > '' and isnull(@history, 'N') = 'N' and  
			(isnull(PayHistAtDest, '') = 'Y' or isnull(Dest_domicile, '') = 'Y' or isnull(rateonfiledest, '') = 'Y' or isnull(RatePaidAtDest, '') = 'Y'))

		or (isnull(@origin, '') > '' and isnull(@destination, '') > '' and isnull(@history, 'N') = 'N'   
			and (isnull(PayHistAtOrigin, '') = 'Y' or isnull(orig_domicile, '') = 'Y' or isnull(rateonfileorigin, '') = 'Y' or isnull(RatePaidAtOrigin, '') = 'Y') 
			and (isnull(PayHistAtDest, '') = 'Y' or isnull(dest_domicile, '') = 'Y' or isnull(rateonfiledest, '') = 'Y' or isnull(RatePaidAtdest, '') = 'Y')		)
		and
		((isnull(@origin, '') > '' and isnull(@destination, '') = '' and isnull(@ratesonly, '')  = 'Y' and isnull(RatePaidAtOrigin, '') = 'Y') 
		or (isnull(@origin, '') = '' and isnull(@destination, '') > '' and isnull(@ratesonly, '')  = 'Y' and isnull(RatePaidAtDest, '') = 'Y') 
		or (isnull(@origin, '') > '' and isnull(@destination, '') > '' and isnull(@ratesonly, '')  = 'Y' and isnull(RatePaidAtOrigin, '') = 'Y' and isnull(RatePaidAtDest, '') = 'Y') 
		or isnull(@ratesonly, 'N') in ('N', '')))	
		and #temp1.trk_carrier = B.trk_carrier)


if  isnull(@origin, '') = '' and isnull(@destination, '') = '' and @history = 'N' and isnull(@ratesonly, 'N') = 'N'
begin
	update #temp1  set totalordersfiltered_comb = crh_total
	update #temp1 set ontimeordersfiltered_comb = crh_ontime
end


-- Percent on time filtered
update #temp1
set percentontimefiltered = ontimeordersfiltered * 100 / totalordersfiltered where totalordersfiltered > 0
update #temp1 set percentontimefiltered = 0 where percentontimefiltered is null


update #temp1
set percentontimefiltered_comb = ontimeordersfiltered_comb * 100 / totalordersfiltered_comb where totalordersfiltered_comb > 0
update #temp1 set percentontimefiltered_comb = 0 where percentontimefiltered_comb is null



update #temp1 set exp_priority1 = 
	(select count(0) from expiration
	where exp_idtype = 'CAR'
	and exp_id = trk_carrier
	and exp_priority = 1
	and exp_completed = 'N'
	and @stp_departure_dt > exp_expirationdate)

update #temp1 set exp_priority2 = 
	(select count(0) from expiration
	where exp_idtype = 'CAR'
	and exp_id = trk_carrier
	and exp_priority > 1
	and exp_completed = 'N'
	and @stp_departure_dt > exp_expirationdate)

update #temp1
	set cty_nmstct = (select city.cty_nmstct from city, carrier
			  where carrier.cty_code = city.cty_code and 
				#temp1.trk_carrier = carrier.car_id)
update #temp1 
	set 	orig_domicile = fcr_origdomicile,
		dest_domicile = fcr_destdomicile,
		keepfromfilter = #temp_filteredcarriers.keepfromfilter
	from #temp1, #temp_filteredcarriers
	where  trk_carrier = fcr_carrier


update #temp1 set haspaymenthist = 'Y', haspaymenthist_comb = 'Y'
	where trk_carrier in (select crh_carrier from carrierhistory)




update #temp1
set MatchResult = MatchResult + ' Carrier has Pay History, '

where HasPaymentHist = 'Y'
	
	update #temp1
	set combinedMatchresult = combinedMatchresult + ' Carrier has Pay History, '
	where trk_carrier in (select trk_carrier from #temp1 where HasPaymentHist = 'Y')


if @origin > ''
begin
	update #temp1
	set MatchResult = MatchResult + ' Pay History at Origin, '
	where PayHistAtOrigin = 'Y'
	
	update #temp1
	set combinedMatchresult = combinedMatchresult + ' Pay History at Origin, ', PayHistAtOrigin_comb = 'Y'
	where trk_carrier in (select trk_carrier from #temp1 where PayHistAtOrigin = 'Y')
end

if @destination > ''
begin
	update #temp1
	set MatchResult = MatchResult + 'Pay History at Destination, '
	where PayHistAtDest = 'Y'

	update #temp1
	set combinedMatchresult = combinedMatchresult + ' Pay History at Destination, ', PayHistAtDest_comb = 'Y'
	where trk_carrier in (select trk_carrier from #temp1 where PayHistAtDest = 'Y')
end

update #temp1
set MatchResult = MatchResult + ' Domicile at Origin, '
where orig_domicile = 'Y'

	update #temp1
	set combinedMatchresult = combinedMatchresult + ' Domicile at Origin, ', orig_domicile_comb = 'Y'
	where trk_carrier in (select trk_carrier from #temp1 where orig_domicile = 'Y')

update #temp1
set MatchResult = MatchResult + ' Domicile at Destination, '
where dest_domicile = 'Y'

	update #temp1
	set combinedMatchresult = combinedMatchresult + ' Domicile at Destination, ', dest_domicile_comb = 'Y'
	where trk_carrier in (select trk_carrier from #temp1 where dest_domicile = 'Y')

update #temp1
set MatchResult = MatchResult + ' Rate on File at Origin, '
where rateonfileorigin = 'Y'

	update #temp1
	set combinedMatchresult = combinedMatchresult + ' Rate on File at Origin, ', rateonfileorigin_comb = 'Y'
	where trk_carrier in (select trk_carrier from #temp1 where rateonfileorigin = 'Y')

update #temp1
set MatchResult = MatchResult + ' Rate on File at Destination, '
where rateonfiledest = 'Y'

	update #temp1
	set combinedMatchresult = combinedMatchresult + ' Rate on File at Destination, ', rateonfiledest_comb = 'Y'
	where trk_carrier in (select trk_carrier from #temp1 where rateonfiledest = 'Y')

update #temp1
set MatchResult = left(MatchResult, len(MatchResult)-1)
where right(rtrim(MatchResult), 1) = ', '

update #temp1
set combinedMatchresult = left(combinedMatchresult, len(combinedMatchresult)-1)
where right(rtrim(combinedMatchresult), 1) = ', '




update #temp1 set orig_domicile = null where orig_domicile = 'N'
update #temp1 set dest_domicile = null where dest_domicile = 'N'


if isnull(@origin, '') > ''
begin
	delete from #temp1 where isnull(PayHistAtOrigin, 'N') = 'N' and isnull(orig_domicile, 'N') = 'N' and isnull(rateonfileorigin, 'N') = 'N' and isnull(RatePaidAtOrigin, 'N') = 'N'
end

if isnull(@Destination, '') > ''
begin
	delete from #temp1 where isnull(PayHistAtDest, 'N') = 'N' and isnull(Dest_domicile, 'N') = 'N' and isnull(rateonfileDest, 'N') = 'N' and isnull(RatePaidAtDest, 'N') = 'N'
end

update #temp1
   set car_exp1date = car_exp1_date,
       car_exp2date = car_exp2_date
  from carrier
 where carrier.car_id = #temp1.trk_carrier

UPDATE	#temp1
   SET	pri1expsoon = CASE
						WHEN car_exp1date <= dateadd(dd, @expdate, getdate()) THEN 1
						ELSE 0
					  END,
	    pri2expsoon = CASE
						WHEN car_exp2date <= dateadd(dd, @expdate, getdate()) THEN 1
						ELSE 0
			 		  END

if @returntariffs = 'N'
begin
	Select 	distinct 0 trk_number,--isnull(trk_number,''), 
		0 tar_number,--isnull(tar_number,0), 
		0 tar_rate,--isnull(tar_rate,0), 
		isnull(trk_carrier,'') trk_carrier,
		isnull(Crh_Total,0) crh_total,
		isnull(Crh_OnTime,0) crh_ontime,
		'' cht_itemcode,--isnull(cht_itemcode,''),
		'' cht_description,--isnull(cht_description,''),
		isnull(crh_percent,'') crh_percent,
		isnull(Crh_AveFuel,0) crh_avefuel,
		isnull(Crh_AveTotal,0) crh_avetotal,
		isnull(Crh_AveAcc,0) crh_aveacc,
		isnull(car_name,'') car_name,
		isnull(car_address1,'') car_address1,
		isnull(car_address2,'') car_address2,
		isnull(car_scac,'') car_scac,
		isnull(car_phone1,'') car_phone1,
		isnull(car_phone2,'') car_phone2,
		isnull(car_contact,'') car_contact,
		isnull(car_phone3,'') car_phone3,
		isnull(car_email,'') car_email,
		'' car_currency,--isnull(car_currency, ''),		-- MRH 11/13/03
		'' cht_currunit,--isnull(cht_currunit, ''),
		isnull(car_rating, '') car_rating,
		isnull(exp_priority1, 0) exp_priority1,		
		isnull(exp_priority2, 0) exp_priority2,
		isnull(cty_nmstct, 0) cty_nmstct,
		isnull(totalordersfiltered_comb, 0) totalordersfiltered,
		isnull(ontimeordersfiltered_comb, 0) ontimeordersfiltered,
		isnull(percentontimefiltered_comb, 0) percentontimefiltered,
		isnull(orig_domicile_comb, '') orig_domicile,
		isnull(dest_domicile_comb, '') dest_domicile,
		--isnull(keepfromfilter, '') keepfromfilter, 
		isnull(rateonfileorigin_comb, '') rateonfileorigin, 
		isnull(rateonfiledest_comb, '') rateonfiledest, 
		isnull(haspaymenthist_comb, '') haspaymenthist, 
		isnull(PayHistAtOrigin_comb, '') PayHistAtOrigin, 
		isnull(PayHistAtDest_comb, '') PayHistAtDest,
		isnull(CombinedMatchResult, '') CombinedMatchResult,
		isnull(RatePaidAtOrigin_comb, '') RatePaidAtOrigin,
		isnull(RatePaidAtDest_comb, '') RatePaidAtDest,
		isnull(cartype1_t, 'Car Type1') cartype1_t,
		isnull(cartype2_t, 'Car Type2') cartype2_t,
		isnull(cartype3_t, 'Car Type3') cartype3_t,
		isnull(cartype4_t, 'Car Type4') cartype4_t,
		isnull(car_type1, 'UNK') car_type1,
		isnull(car_type2, 'UNK') car_type2,
		isnull(car_type3, 'UNK') car_type3,
		isnull(car_type4, 'UNK') car_type4,
		isnull(pri1expsoon, 0)		pri1expsoon,
		isnull(pri2expsoon,0)		pri2expsoon,
		last_used,
		ISNULL(total_billed,0) total_billed,
		ISNULL(total_paid,0) total_paid
	from #temp1	
   --where #temp1.trk_carrier in (select car_id from carrier)
   where  #temp1.trk_carrier in (select car_id from carrier where car_status <> 'OUT')  --pts43941
	and ((@ratesonly = 'Y' and tar_number > 0) or isnull(@ratesonly, 'N') IN ('N', ''))
		and ((@history = 'Y' and @origin > '' and PayHistAtOrigin = 'Y')  
		or (@history = 'Y' and @destination > '' and PayHistAtDest = 'Y')  
		or (@history = 'Y' and isnull(@origin, '') > '' and PayHistAtOrigin = 'Y' and isnull(@destination, '') > '' and PayHistAtDest = 'Y')  
		or (@history = 'Y' and isnull(@origin, '') = '' and isnull(@destination, '') = '' and haspaymenthist = 'Y')
		or @history = 'N')
	--or ((@history = 'N' and @origin > '') and (PayHistAtOrigin = 'Y' or orig_domicile = 'Y' or rateonfileorigin = 'Y' or RatePaidAtOrigin = 'Y'))
	
-- make sure no hist but orig displays only orig stuff.  Need 4 more		

end 
else  -- car pmt hist floating window, @returntariffs = y
begin
	Select 	distinct isnull(trk_number,'') trk_number, 
		isnull(tar_number,0) tar_number, 
		isnull(tar_rate,0) tar_rate, 
		isnull(trk_carrier,'') trk_carrier,
		isnull(Crh_Total,0) crh_total,
		isnull(Crh_OnTime,0) crh_ontime,
		isnull(cht_itemcode,'') cht_itemcode,
		isnull(cht_description,'') cht_description,
		isnull(crh_percent,'') crh_percent,
		isnull(Crh_AveFuel,0) crh_avefuel,
		isnull(Crh_AveTotal,0) crh_avetotal,
		isnull(Crh_AveAcc,0) crh_aveacc,
		isnull(car_name,'') car_name,
		isnull(car_address1,'') car_address1,
		isnull(car_address2,'') car_address2,
		isnull(car_scac,'') car_scac,
		isnull(car_phone1,'') car_phone1,
		isnull(car_phone2,'') car_phone2,
		isnull(car_contact,'') car_contact,
		isnull(car_phone3,'') car_phone3,
		isnull(car_email,'') car_email,
		isnull(car_currency, '') car_currency,		-- MRH 11/13/03
		isnull(cht_currunit, '') cht_currunit,
		isnull(car_rating, '') car_rating,
		isnull(exp_priority1, 0) exp_priority1,		
		isnull(exp_priority2, 0) exp_priority2,
		isnull(cty_nmstct, 0) cty_nmstct,
		isnull(totalordersfiltered, 0) totalordersfiltered,
		isnull(ontimeordersfiltered, 0) ontimeordersfiltered,
		isnull(percentontimefiltered, 0) percentontimefiltered,
		isnull(orig_domicile, '') orig_domicile,
		isnull(dest_domicile, '') dest_domicile,
		------isnull(keepfromfilter, '') keepfromfilter,
		isnull(rateonfileorigin, '') rateonfileorigin, 
		isnull(rateonfiledest, '') rateonfiledest, 
		isnull(haspaymenthist, '') haspaymenthist, 
		isnull(PayHistAtOrigin, '') PayHistAtOrigin, 
		isnull(PayHistAtDest, '') PayHistAtDest,
		--isnull(RatePaidAtOrigin, '') RatePaidAtOrigin,
		--isnull(RatePaidAtDest, '') RatePaidAtDest,		
		isnull(MatchResult, '') MatchResult, 
--	isnull(CombinedMatchResult, '') CombinedMatchResult 
		isnull(RatePaidAtOrigin, '') RatePaidAtOrigin,
		isnull(RatePaidAtDest, '') RatePaidAtDest, 
		isnull(cartype1_t, 'Car Type1') cartype1_t,
		isnull(cartype2_t, 'Car Type2') cartype2_t,
		isnull(cartype3_t, 'Car Type3') cartype3_t,
		isnull(cartype4_t, 'Car Type4') cartype4_t,
		isnull(car_type1, 'UNK') car_type1,
		isnull(car_type2, 'UNK') car_type2,
		isnull(car_type3, 'UNK') car_type3,
		isnull(car_type4, 'UNK') car_type4,
		isnull(pri1expsoon, 0)		pri1expsoon,
		isnull(pri2expsoon,0)		pri2expsoon,
		last_used,
		ISNULL(total_billed, 0) total_billed,
		ISNULL(total_paid, 0) total_paid
	from #temp1	
	--where #temp1.trk_carrier in (select car_id from carrier)		  JLB PTS 43941
   where  #temp1.trk_carrier in (select car_id from carrier where car_status <> 'OUT')  --pts43941
	and ((@ratesonly = 'Y' and tar_number > 0) or isnull(@ratesonly, 'N') IN('N', ''))
	and ((@history = 'Y' and @origin > '' and PayHistAtOrigin = 'Y')  
		or (@history = 'Y' and @destination > '' and PayHistAtDest = 'Y')  
		or (@history = 'Y' and isnull(@origin, '') > '' and PayHistAtOrigin = 'Y' and isnull(@destination, '') > '' and PayHistAtDest = 'Y')  
		or (@history = 'Y' and isnull(@origin, '') = '' and isnull(@destination, '') = '' and haspaymenthist = 'Y')
		or @history = 'N')	
	
end 


GO
GRANT EXECUTE ON  [dbo].[d_cmpcarrier_sp] TO [public]
GO
