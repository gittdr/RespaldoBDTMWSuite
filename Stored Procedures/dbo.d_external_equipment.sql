SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*****************************************************************************************
Revisions:
Originally built for Command Transport
35209 BDH 12/1/2006  	Incorporated carrier filter logic and added destination logic.

36145 JET 2/13/2007		include ete_source in the return set
36229 JET 2/13/2007		include active carriers from the carrier profile/include carriers
                        on active trips in return set
37106 BDH 12/4/2007		Instead of passing in view_id, we pass in each arg so they can adhoc change on the External Equip tab.
43267 KMM 7/26/08		Change age to be a pad as many zeros as needed to make sure 5 positions are to the left of the ':'
44005 JLB 09/17/2008	Add cartype_1 to result set
45270 DJM 1/6/2009		Add the ete_mc number field (car_iccnum) to the external equipment
46503 JLB 4/10/2009		Add cartype_2 - 4 to result set
56037 DJM 6/9/2011		Modify the retrieveal to include the Expired date in the retrieval
96868 BMB 1/8/2016		Including the new ete_lgh_number column from external_equipment
96868 BMB 2/18/2016		Fixing faulty date range logic
******************************************************************************************/

-- DO NOT ADD PARAMETERS TO THIS PROC without arranging for .Net group to make corresponding changes to DispatchObjects.ExternalEquipmentDAL

create procedure [dbo].[d_external_equipment] (
	--PTS 50742 JJF 20100216
	@ete_equipmenttype_valuetype varchar(6),
	@ete_equipmenttype 	varchar(25),
	@ete_origincity		varchar(50),
	@ete_originradius	int,
	@ete_destcity		varchar(50),
	@ete_destradius		int,
	@ete_loadtype		varchar(10),
	@ete_equipmentlength	varchar(50),
	@ete_loadweight		decimal(10,4),
	@ete_availabledatefrom	datetime,
	@ete_availabledateto	datetime,
	@ete_posting_hoursold	int, 
    	@lgh_booked_revtype1    varchar(256), -- = Branch
	--    @caf_viewid varchar(6) = ''
	@caf_car_type1 varchar(6),	-- 40500 BDH.  16 new args.  View_id no longer needed.
	@caf_car_type2 varchar(6),	
	@caf_car_type3 varchar(6),		
	@caf_car_type4 varchar(6),
	@caf_liability_limit money,	
	@caf_cargo_limit money,	
	@caf_service_rating varchar(6),	
	@carrier varchar(8),	  -- car_id
	@caf_ins_cert char(1),	
	@caf_w9 char(1),		
	@caf_contract char(1),		
	@history char(1),
	@trcaccess varchar(1000),	
	@trlaccess varchar(1000),
	@drvqual varchar(1000),	
	@carqual varchar(1000)
	)

	
AS

-- Make temp table for results
CREATE TABLE #results (
  ete_id            	int not null, 
  ete_source        	varchar(20) null, 
  ete_sourcerefnumber	varchar(20) null, 
  ete_origlocation  	varchar(8) null, 
  ete_origcity      	varchar(50) null, 
  ete_origstate     	varchar(6) null, 
  ete_origzip   		varchar(10) null, 
  ete_origlatitude      decimal(8, 4) null, 
  ete_origlongitude     decimal(8,4) null, 
  ete_dhmiles_origin	int null, 
  ete_destlocation  	varchar(8) null, 
  ete_destcity      	varchar(50) null, 
  ete_destcitysearch	varchar(50) null, 
  ete_deststate			varchar(6) null, 
  ete_destzip       	varchar(10) null, 
  ete_destlatitude  	decimal(8, 4) null, 
  ete_destlongitude 	decimal(8, 4) null, 
  ete_dhmiles_dest  	int null, 
  ete_availabledate 	datetime null, 
  ete_postingdate   	datetime null, 
  ete_postingage    	varchar(20) null,
  ete_expirationdate	datetime null, 
  ete_equipmenttype 	varchar(25) null, 
  ete_loadtype      	varchar(10) null, 
  ete_equipmentlength	varchar(50) null, 
  ete_loadweight    	decimal(12, 4) null, 
  ete_carrierid	    	varchar(8) null, 
  ete_carriername   	varchar(100) null, 
  ete_carrierstate  	varchar(2) null, 
  ete_carriermcnumber	int null, 
  ete_contactname   	varchar(50) null, 
  ete_contactphone  	varchar(25) null, 
  ete_contactaltphone	varchar(25) null, 
  ete_truckcount    	smallint null, 
  ete_truckid       	varchar(50) null, 
  ete_created       	datetime null, 
  ete_createdby			varchar(128) null, 
  ete_updated       	datetime null, 
  ete_updatedby			varchar(128) null,
  ete_truck_mcnum		varchar(50) null, 
  ete_driver_name		varchar(255) null, 
  ete_driver_phone		varchar(25) null, 
  branch_t		varchar(25) null, 
  branch		varchar(12) null,
  dont_delete	    	char(1) not null default ('N'),
  ete_remarks	varchar(255) null,
  ete_status	varchar(6) null,
  cartype1_t	varchar(20) null,
  cartype2_t	varchar(20) null,
  cartype3_t	varchar(20) null,
  cartype4_t	varchar(20) null,
  car_type1		varchar(6) null,
  car_type2		varchar(6) null,
  car_type3		varchar(6) null,
  car_type4		varchar(6) null,
  ete_mc				varchar(12) null,	-- PTS 45270 - MC# = car_iccnum field in carrier table.
	--PTS 46005 JJF 20090325
	ete_automatch		char(1),
	ete_originradius	int	null,
	ete_destradius		int	null,
	--END PTS 46005 JJF 20090325
	ete_lgh_number		INT NULL
)

create table #temp_filteredcarriers (fcr_carrier varchar(8), keepfromfilter char(1) null)


DECLARE
	@cur_origlat		decimal(10,4),
	@cur_origlong		decimal(10,4),
	@ete_ocity			varchar(50),
	@ete_originlat		decimal(10,4),
	@ete_originlong		decimal(10,4),
	@ete_originstate	varchar(6),
	@use_ocityonly		char(1),
	@use_ocitystate		char(1),
	@use_origstates		char(1),
	@origin_miles		decimal(12,6),
	@origstatestouse	varchar(200),
	@origzonestouse		varchar(200),
	@cur_destlat		decimal(10,4),
	@cur_destlong		decimal(10,4),
	@ete_dcity			varchar(50),
	@ete_destlat		decimal(10,4),
	@ete_destlong		decimal(10,4),
	@ete_deststate		varchar(6),
	@ete_destcity_orig	varchar(50), 	
	@use_dcityonly		char(1),
	@use_dcitystate		char(1),
	@use_deststates		char(1),
	@use_destzones		char(1),
	@dest_miles		decimal(12,6),
	@deststatestouse	varchar(200),
	@destzonestouse		varchar(200),
	@ete_commapos		smallint,
	@last_ete_id		int,
	@branch_t		varchar(25),
	@chunk			char(2), 
    	@state              	varchar(6), 
    	@zone               	varchar(6),
	@count			int,
	@current_car 		varchar(8),
	@temp_id 		int,
	@temp_value		varchar(8),
	@stp_departure_dt	datetime,  -- set to today, used for expirations only. 
	--PTS 49543 JJF 20091021 
	--@ete_slashpos	varchar(1000),
	@slashpos         SMALLINT,
	@ls_ocounty			varchar(3),
	@ls_dcounty			varchar(3),
	--PTS 49543 JJF 20091021 
        @parse			VARCHAR(50),
        @pos			INTEGER,
	@where 			VARCHAR(1000),
	@sql			NVARCHAR(1000)

create table #temp_values (temp_id int identity, value varchar(8))

set @stp_departure_dt = getdate()

-- filter stuff
--declare
--     @caf_car_type1		varchar(6),
-- 	@caf_car_type2		varchar(6),
-- 	@caf_car_type3		varchar(6),
-- 	@caf_car_type4		varchar(6),
-- 	@caf_liability_limit money,
-- 	@caf_cargo_limit	money, 
-- 	@caf_service_rating	varchar(6),
-- 	@caf_ins_cert		char(1),
-- 	@caf_w9				char(1),
-- 	@caf_contract		char(1),
-- 	@carrier			varchar(8),
	

BEGIN

IF @lgh_booked_revtype1 IS NULL OR RTRIM(@lgh_booked_revtype1) = '' or @lgh_booked_revtype1 = 'UNKNOWN'
	SELECT @lgh_booked_revtype1 = ''

--PTS 50742 JJF 20100216
--IF @ete_equipmenttype IS NULL OR RTRIM(@ete_equipmenttype) = ''
--	SELECT @ete_equipmenttype = 'ALL'
IF @ete_equipmenttype IS NULL OR RTRIM(@ete_equipmenttype) = '' BEGIN
	SELECT @ete_equipmenttype_valuetype = 'ALL'
	SELECT @ete_equipmenttype = 'ALL'
END
IF @ete_equipmenttype_valuetype IS NULL OR RTRIM(@ete_equipmenttype_valuetype) = '' BEGIN
	SELECT @ete_equipmenttype_valuetype = 'ITEM'
END
IF @ete_equipmenttype = 'UNKNOWN' BEGIN
	SELECT @ete_equipmenttype_valuetype = 'ALL'
	SELECT @ete_equipmenttype = 'ALL'
END 
--END PTS 50742 JJF 20100216


IF @ete_loadtype IS NULL OR RTRIM(@ete_loadtype) = ''
	SELECT @ete_loadtype = 'ALL'

IF @ete_equipmentlength IS NULL OR RTRIM(@ete_equipmentlength) = ''
	SELECT @ete_equipmentlength = 'ALL'

--PTS 49543 JJF 20091021 handle UNKNOWN as blank (wildcard)
--IF @ete_origincity IS NULL OR RTRIM(@ete_origincity) = ''
IF @ete_origincity IS NULL OR RTRIM(@ete_origincity) = '' OR @ete_origincity = 'UNKNOWN'
--END PTS 49543 JJF 20091021 handle UNKNOWN as blank (wildcard)
	SELECT @ete_origincity = ''

IF @ete_originradius IS NULL 
	SELECT @ete_originradius = 0

--PTS 49543 JJF 20091021 handle UNKNOWN as blank (wildcard)
--IF @ete_destcity IS NULL OR RTRIM(@ete_destcity) = ''
IF @ete_destcity IS NULL OR RTRIM(@ete_destcity) = '' OR @ete_destcity = 'UNKNOWN'
	SELECT @ete_destcity = ''

IF @ete_destradius IS NULL 
	SELECT @ete_destradius = 0

IF @ete_originradius IS NULL 
	SELECT @ete_loadweight = 0

IF @ete_availabledatefrom IS NULL OR @ete_availabledatefrom = '19000101'
	SELECT @ete_availabledatefrom = '19500101'

IF @ete_availabledateto IS NULL OR @ete_availabledateto = '19000101'
	SELECT @ete_availabledateto = '20491231 23:59'

IF @ete_posting_hoursold IS NULL
	SELECT @ete_posting_hoursold = 0

If @ete_posting_hoursold > 0 
	SELECT @ete_posting_hoursold = -1 * @ete_posting_hoursold

select @branch_t = isnull(gi_string3, 'Branch') 
  from generalinfo 
 where gi_name = 'TrackBranch'

set @use_ocityonly = 'N'
set @use_ocitystate = 'N'
set @origzonestouse = ','
set @origstatestouse = ','
set @use_origstates = 'N'

if len(ltrim(rtrim(isnull(@ete_origincity, '')))) > 0
begin
	-- Parse Origin
	SELECT @ete_commapos = CHARINDEX(',', @ete_origincity)
	--PTS 49543 JJF 20091021 
	--select @ete_slashpos = CHARINDEX('/', @ete_origincity)
	SET @slashpos = CHARINDEX('/', @ete_origincity)

	If @ete_commapos > 0 
	-- Has a comma, must be a city state
	BEGIN
		IF @slashpos > 0 
		BEGIN
			SELECT @use_ocitystate = 'Y' 
			SELECT @ete_ocity = RTRIM(LTRIM(LEFT(@ete_origincity, @ete_commapos - 1))) 
			SELECT @ete_originstate = RTRIM(LTRIM(SUBSTRING(@ete_origincity,  @ete_commapos + 1, @slashpos -  (@ete_commapos + 1)))) 
			SET @ls_ocounty = RTRIM(LTRIM(RIGHT(@ete_origincity, (LEN(@ete_origincity) - @slashpos))))
			SET @ls_ocounty = SUBSTRING(@ls_ocounty, 1, 3)
			
			IF rtrim(ltrim(isnull(@ls_ocounty, ''))) <> ''
			BEGIN
				SELECT @ete_origincity = @ete_ocity 
				SELECT @ete_originlat = cty_latitude, 
					   @ete_originlong = cty_longitude 
  				  FROM city 
 				 WHERE cty_name = @ete_origincity
   				   AND cty_state = @ete_originstate	 
   				   AND cty_county = @ls_ocounty
			END
			ELSE
			BEGIN
				SELECT @ete_origincity = @ete_ocity 
				SELECT @ete_originlat = cty_latitude, 
					   @ete_originlong = cty_longitude 
  				  FROM city 
 				 WHERE cty_name = @ete_origincity
   				   AND cty_state = @ete_originstate	 
			END
		END
		ELSE
		BEGIN
			SELECT @use_ocitystate = 'Y' 
			SELECT @ete_ocity = RTRIM(LTRIM(LEFT(@ete_origincity, @ete_commapos - 1))) 
			SELECT @ete_originstate = RTRIM(LTRIM(SUBSTRING(@ete_origincity, @ete_commapos + 1, 99))) 


			SELECT @ete_origincity = @ete_ocity 
			SELECT @ete_originlat = cty_latitude, 
				   @ete_originlong = cty_longitude 
  			  FROM city 
 			 WHERE cty_name = @ete_origincity
   			   AND cty_state = @ete_originstate	 
		END
	END
		--END PTS 49543 JJF 20091021 
	ELSE
	-- see if we have origin states, zones, or both or see if the value is a city name with no state.
	begin	
		--PTS 50115 jjf 20091208 - It's possible for state lists (which aren't comma separated) to match city names (COMO for instance).
		--if exists (select 1 from city where cty_name = ltrim(rtrim(@ete_origincity)))
		--   set @use_ocityonly = 'Y'
		--else
		--END PTS 50115 jjf 20091208 - It's possible for state lists (which aren't comma separated) to match city names (COMO for instance).
		if len(@ete_origincity) > 1 set @chunk = substring(@ete_origincity, 1, 2)
		While len(@chunk) > 0 
		begin	
			if substring(@chunk, 1, 1) = 'Z' and @chunk in (select distinct tcz_zone from transcore_zones)
			begin
				set @use_origstates = 'Y'
				set @origzonestouse = @origzonestouse + @chunk + ','
			end
			else
			begin
				if @chunk in (select distinct tcz_state from transcore_zones)
				begin
					set @use_origstates = 'Y'
					set @origzonestouse = @origzonestouse + @chunk + ','
				end
			end
		
			If (len(@ete_origincity) -2) >= 0
				set @ete_origincity = right(@ete_origincity, len(@ete_origincity) -2)
			if len(@ete_origincity) > 1 set @chunk = substring(@ete_origincity, 1, 2) else break
		end
	end
end

if @use_origstates = 'Y'
begin
	select @chunk = min(tcz_state) from transcore_zones where charindex(tcz_zone, @origzonestouse) > 0 or charindex(tcz_state, @origzonestouse) > 0
	While len(@chunk) > 0 
	begin
		set @origstatestouse = @origstatestouse + @chunk + ','
        
	    select @chunk = min(tcz_state) from transcore_zones where (charindex(tcz_zone, @origzonestouse) > 0 or charindex(tcz_state, @origzonestouse) > 0) and tcz_state > @chunk
	end
end

-- search external equipment for equipment matching the origin restrictions
INSERT INTO #results (ete_id, ete_source, ete_sourcerefnumber, ete_origlocation, 
                  ete_origcity, ete_origstate, ete_origzip, ete_origlatitude, 
                  ete_origlongitude, ete_dhmiles_origin, ete_destlocation, ete_destcity, 
                  ete_destcitysearch, ete_deststate, ete_destzip, ete_destlatitude, 
                  ete_destlongitude, ete_dhmiles_dest, ete_availabledate, ete_postingdate, 
                  ete_postingage, ete_expirationdate, ete_equipmenttype, ete_loadtype, 
                  ete_equipmentlength, ete_loadweight, ete_carrierid, ete_carriername, 
                  ete_carrierstate, ete_carriermcnumber, ete_contactname, ete_contactphone, 
                  ete_contactaltphone, ete_truckcount, ete_truckid, ete_created, ete_createdby,
                  ete_updated, ete_updatedby, ete_truck_mcnum, ete_driver_name, ete_driver_phone, 
                  branch_t, branch, ete_remarks, ete_status, cartype1_t, cartype2_t, cartype3_t, 
                  cartype4_t, car_type1, car_type2, car_type3, car_type4, ete_mc,
					--PTS 46005 JJF 20090325
					ete_automatch,
					ete_originradius, 
					ete_destradius,
					--END PTS 46005 JJF 20090325
					ete_lgh_number
			) 
          (SELECT ete_id, ete_source, ete_sourcerefnumber, ete_origlocation, 
                  ete_origcity, ete_origstate, ete_origzip, ete_origlatitude, 
                  ete_origlongitude, 0, ete_destlocation, ete_destcity, 
                  CASE WHEN RTRIM(LTRIM(ISNULL(ete_deststate, ''))) <> '' THEN ete_destcity ELSE ',' + LEFT(ete_destcity,2) + ',' + SUBSTRING(ete_destcity,3,2) + ',' + SUBSTRING(ete_destcity,5,2) + ',' + SUBSTRING(ete_destcity,7,2) + ',' + SUBSTRING(ete_destcity,9,2) + ',' + SUBSTRING(ete_destcity,11,2) + ',' + SUBSTRING(ete_destcity,13,2) + ',' END, 
                  ete_deststate, ete_destzip, ete_destlatitude, 
                  ete_destlongitude, 0, ete_availabledate, ete_postingdate, 
                  replicate('0', 5-len(CONVERT(VARCHAR, (DATEDIFF(mi, ete_postingdate, GETDATE())/60)))) + CONVERT(VARCHAR, (DATEDIFF(mi, ete_postingdate, GETDATE())/60)) + ':' + (CASE WHEN DATEDIFF(mi, ete_postingdate, GETDATE()) % 60 < 10 THEN '0' + CONVERT(VARCHAR, DATEDIFF(mi, ete_postingdate, getdate()) % 60) else convert(varchar, datediff(mi, ete_postingdate, getdate()) % 60) END), 
                  ete_expirationdate, IsNull(ete_equipmenttype, ''), ete_loadtype, 
                  ete_equipmentlength, ete_loadweight, ete_carrierid, ete_carriername, 
                  ete_carrierstate, ete_carriermcnumber, ete_contactname, ete_contactphone, 
                  ete_contactaltphone, ete_truckcount, ete_truckid, ete_created, ete_createdby, 
                  ete_updated, 	ete_updatedby, ete_truck_mcnum, ete_driver_name, ete_driver_phone, 
                  @branch_t, isnull(car_branch, 'UNKNOWN'), ete_remarks, ete_status, 
                  (select max(cartype1) from labelfile_headers) as 'cartype1_t', 
                  (select max(cartype2) from labelfile_headers) as 'cartype2_t', 
                  (select max(cartype3) from labelfile_headers) as 'cartype3_t', 
                  (select max(cartype4) from labelfile_headers) as 'cartype4_t', 
                   carrier.car_type1,
                   carrier.car_type2,
                   carrier.car_type3,
                   carrier.car_type4,
				  ete_mc,	-- PTS 45270
					--PTS 46005 JJF 20090325
					ete_automatch,
					ete_originradius,
					ete_destradius,
					--END PTS 46005 JJF 20090325
					ete_lgh_number
             FROM external_equipment WITH (nolock) 
                  LEFT OUTER JOIN carrier ON external_equipment.ete_carrierid = carrier.car_id 
            --PTS 50742 JJF 20100216
            --WHERE (CHARINDEX(',' + ISNULL(ete_equipmenttype, 'ALL') + ',', ',' + @ete_equipmenttype + ',') > 0 OR 
            --       @ete_equipmenttype = 'ALL') 
			--PTS 51645 JJF 20100326 - use abbr instead of name
			WHERE	(	(	@ete_equipmenttype_valuetype = 'ALL') OR
						(	ete_equipmenttype IS NULL) OR
						(	(	@ete_equipmenttype_valuetype = 'GROUP') AND
							(	ete_equipmenttype IN	(	SELECT	abbr
															FROM	labelfile
															WHERE	(labeldefinition = 'ExtEquipmentType') AND 
																	(label_extrastring1 = @ete_equipmenttype)
														)
							)
						) OR
						(	@ete_equipmenttype_valuetype = 'ITEM'
							AND CHARINDEX(',' + ete_equipmenttype + ',', ',' + @ete_equipmenttype + ',') > 0
						)
					)
			--END PTS 50742 JJF 20100216
              AND (CHARINDEX(',' + ISNULL(ete_loadtype, 'ALL') + ',', ',' + @ete_loadtype + ',') > 0  OR
                   @ete_loadtype = 'ALL') 
              AND (CHARINDEX(',' + ISNULL(ete_equipmentlength, 'ALL') + ',', ',' + @ete_equipmentlength + ',') > 0 OR 
                   @ete_equipmentlength = 'ALL') 
              AND (CHARINDEX(',' + ISNULL(carrier.car_branch, 'UNKNOWN') + ',', ',' + @lgh_booked_revtype1 + ',') > 0 OR 
                   @lgh_booked_revtype1 = '') 
              AND ISNULL(ete_loadweight, 0) >= @ete_loadweight 
              AND (
					(ete_availabledate BETWEEN @ete_availabledatefrom AND @ete_availabledateto)
					OR (ete_expirationdate BETWEEN @ete_availabledatefrom AND @ete_availabledateto)
					OR (ete_availabledate <= @ete_availabledatefrom AND ete_expirationdate >= @ete_availabledateto) )
              AND ete_postingdate >= DATEADD(hh, @ete_posting_hoursold, GETDATE()) 
              AND ete_status = 'AVL' 
              AND ete_expirationdate >= GetDate() 
              AND ((@use_ocitystate = 'Y' and @ete_originradius < 1 and ltrim(rtrim(ete_origcity)) = ltrim(rtrim(@ete_origincity)) 
	                 and ltrim(rtrim(ete_origstate)) = ltrim(rtrim(@ete_originstate))) or @use_ocitystate = 'N' or @ete_originradius > 0)
              AND ((@use_ocityonly = 'Y' and ltrim(rtrim(ete_origcity)) = ltrim(rtrim(@ete_origincity))) or @use_ocityonly = 'N')
              AND ((@use_origstates = 'Y' and charindex(ltrim(rtrim(ete_origstate)), @origstatestouse) > 0) or @use_origstates = 'N')
                  )
---------------------------------------------------------------------------------------------------------------------------------------------------

-- include carriers on active trips in the external equipment grid
--PTS 48978 JJF 20090914 - equipment type to come from legheader_active.trl_type1
--PTS 48978 JJF 20090914 - add ete_mc
--PTS 48978 JJF/DM 20090915 - add ete_expirationdate
--PTS 48978 JJF 20090915 - add ete_expirationdate
IF (SELECT ISNULL(gi_string1, 'N') FROM generalinfo WHERE gi_name = 'IncludeActiveTripCarriers') = 'Y'
	INSERT INTO #results (ete_id, ete_postingage, ete_postingdate, ete_availabledate, 
                          ete_dhmiles_origin, ete_origlocation, ete_origcity, ete_origstate, ete_origlatitude, ete_origlongitude, 
                          ete_carrierid, ete_carriername, ete_contactname, ete_contactphone, 
                          ete_truckid, ete_driver_name, ete_driver_phone, ete_loadtype,
                          branch_t, branch, ete_source, ete_equipmenttype, ete_automatch, ete_originradius, ete_destradius,
                          ete_destcity, ete_remarks, ete_mc, ete_expirationdate, ete_sourcerefnumber) 
   SELECT DISTINCT 
          0, replicate('0', 5-len(convert(varchar, DATEDIFF(hh, lgh_enddate, GetDate())))) + convert(varchar, DATEDIFF(hh, lgh_enddate, GetDate())) , GetDate(), lgh_enddate, 
          0, convert(varchar(8), cmp_id_end), convert(varchar(50), cty_name), convert(varchar(6), lgh_endstate), lgh_endlat, lgh_endlong, 
          convert(varchar(8), lgh_carrier), convert(varchar(100), car_name), convert(varchar(50), car_contact), convert(varchar(25), car_phone1), 
          convert(varchar(50), lgh_carrier_truck), convert(varchar(255), lgh_driver_name), convert(varchar(25), lgh_driver_phone), external_equipment.ete_loadtype,
          @branch_t, convert(varchar(12), isnull(car_branch, 'UNKNOWN')), 'Continuous Move', legheader_active.ord_trl_type1, 'N','0','0',
          --PTS 49132 JJF 20090917
		--'UNKNOWN', 'Not Specified', carrier.car_iccnum, getdate() + 1, CONVERT(varchar(20), legheader_active.lgh_number) 
		'UNKNOWN', 'Not Specified', carrier.car_iccnum, dateadd(dd, 1, lgh_enddate), CONVERT(varchar(20), legheader_active.lgh_number) 
     FROM legheader_active left outer join legheader_brokered ON legheader_active.lgh_number = legheader_brokered.lgh_number 
                           join city ON legheader_active.lgh_endcity = city.cty_code 
                           join carrier ON (legheader_active.lgh_carrier = carrier.car_id and carrier.car_status = 'ACT' 
                                            AND (CHARINDEX(',' + ISNULL(carrier.car_branch, 'UNKNOWN') + ',', ',' + @lgh_booked_revtype1 + ',') > 0 OR @lgh_booked_revtype1 = ''))
						   left outer join external_equipment ON legheader_brokered.lgh_ete_id = external_equipment.ete_id
	--52407 JJF 20100519 add equipment type
    WHERE 	(	(	@ete_equipmenttype_valuetype = 'ALL') OR
				(	legheader_active.ord_trl_type1 IS NULL) OR
				(	(	@ete_equipmenttype_valuetype = 'GROUP') AND
					(	legheader_active.ord_trl_type1 IN	(	SELECT	abbr
																FROM	labelfile
																WHERE	(labeldefinition = 'ExtEquipmentType') AND 
																		(label_extrastring1 = @ete_equipmenttype)
															)
					)
				) OR
				(	@ete_equipmenttype_valuetype = 'ITEM'
					AND CHARINDEX(',' + legheader_active.ord_trl_type1 + ',', ',' + @ete_equipmenttype + ',') > 0
				)
			)
            AND (CHARINDEX(',' + ISNULL(external_equipment.ete_loadtype, 'ALL') + ',', ',' + @ete_loadtype + ',') > 0  OR @ete_loadtype = 'ALL')
			AND	legheader_active.lgh_carrier <> 'UNKNOWN' 
			AND legheader_active.lgh_outstatus in ('DSP','STD','CMP')
			--AND ABS(@ete_posting_hoursold) >= DATEDIFF(hh, lgh_enddate, GetDate()) 
			AND ((@use_ocitystate = 'Y' and @ete_originradius < 1 and ltrim(rtrim(cty_name)) = ltrim(rtrim(@ete_origincity)) 
				and ltrim(rtrim(cty_state)) = ltrim(rtrim(@ete_originstate))) or @use_ocitystate = 'N' or @ete_originradius > 0)
			AND ((@use_ocityonly = 'Y' and ltrim(rtrim(cty_name)) = ltrim(rtrim(@ete_origincity))) or @use_ocityonly = 'N')
			AND ((@use_origstates = 'Y' and charindex(ltrim(rtrim(cty_state)), @origstatestouse) > 0) or @use_origstates = 'N')
			--PTS 49132 JJF 20090917
			AND NOT EXISTS (SELECT * FROM external_equipment eqinner where ete_source  = 'Continuous Move Imp' and ete_sourcerefnumber = legheader_active.lgh_number)
			--AND dateadd(dd, 1, lgh_enddate) >= GETDATE()
/*JLB PTS 44137 Per Keith Mader this feature is no longer supported 
-- include active carriersin the external equipment grid
IF (SELECT ISNULL(gi_string1, 'N') FROM generalinfo WHERE gi_name = 'IncludeActiveCarriers') = 'Y'
	INSERT INTO #results (ete_id, ete_postingage, ete_postingdate, ete_availabledate, ete_equipmenttype, ete_loadtype, 
                          ete_dhmiles_origin, ete_origlocation, ete_origcity, ete_origstate, ete_origlatitude, ete_origlongitude, 
                          ete_carrierid, ete_carriername, ete_contactname, ete_contactphone, 
                          ete_equipmentlength, ete_loadweight, ete_truckcount, 
                          ete_truckid, ete_driver_name, ete_driver_phone, branch_t, branch, ete_source, cartype1_t, car_type1)
   SELECT DISTINCT 
          0, 99999, NULL, NULL, '', '', 
          0, 'UNKNOWN', cty_name, cty_state, cty_latitude, cty_longitude, 
          car_id, car_name, car_contact, car_phone1, 
          NULL, NULL, 0, 
          NULL, NULL, NULL, @branch_t, isnull(car_branch, 'UNKNOWN'), 'TMWFILEMNT',
          (select max(cartype1) from labelfile_headers) as 'cartype1_t', carrier.car_type1 
     FROM carrier JOIN city ON (carrier.cty_code = city.cty_code)
    --WHERE carrier.car_id NOT IN (SELECT DISTINCT ete_carrierid FROM #results)   JLB PTS 44137
    WHERE carrier.car_id NOT IN (select distinct ete_carrierid 
                                   from #results join carrier on #results.car_id = carrier.car_id
                                   join city on city.cty_code = carrier.cty_code
                                  where city.cty_name <> #results.cty_name
                                    and city.cty_state <> #results.cty_state)
      AND carrier.car_id <> 'UNKNOWN' 
      AND carrier.car_status = 'ACT'
      AND (CHARINDEX(',' + ISNULL(carrier.car_branch, 'UNKNOWN') + ',', ',' + @lgh_booked_revtype1 + ',') > 0 OR @lgh_booked_revtype1 = '')
      AND ((@use_ocitystate = 'Y' and @ete_originradius < 1 and ltrim(rtrim(cty_name)) = ltrim(rtrim(@ete_origincity)) 
            and ltrim(rtrim(cty_state)) = ltrim(rtrim(@ete_originstate))) or @use_ocitystate = 'N' or @ete_originradius > 0)
      AND ((@use_ocityonly = 'Y' and ltrim(rtrim(cty_name)) = ltrim(rtrim(@ete_origincity))) or @use_ocityonly = 'N')
      AND ((@use_origstates = 'Y' and charindex(ltrim(rtrim(cty_state)), @origstatestouse) > 0) or @use_origstates = 'N')
*/

-- remove entries where the origin city is not within the radius specified
if @use_ocitystate = 'Y' and @ete_originradius > 0 
begin
	UPDATE #results 
		SET ete_dhmiles_origin = dbo.tmw_airdistance_fn(@ete_originlat, @ete_originlong, ete_origlatitude, ete_origlongitude) 

	-- CLEAR OUT RECORDS THAT DON'T MATCH RADIUS CRITERIA
	delete #results 
     where ete_dhmiles_origin > @ete_originradius 
        or ISNULL(ete_origlatitude, 0) = 0 
        or ISNULL(ete_origlongitude, 0) = 0 
end
---------------------------------------------------------------------------------------------------------------------------------------------------

set @use_dcityonly = 'N'
set @use_dcitystate = 'N'
set @destzonestouse = ''
set @use_destzones = 'N' 
set @deststatestouse = ''
set @use_deststates = 'N'
set @ete_destcity_orig = @ete_destcity

if len(ltrim(rtrim(isnull(@ete_destcity, '')))) > 0
begin
	-- Parse Destination
	SELECT @ete_commapos = CHARINDEX(',', @ete_destcity) 
	--PTS 49543 JJF 20091021 
	SET @slashpos = CHARINDEX('/', @ete_destcity)
	--END PTS 49543 JJF 20091021 
	If @ete_commapos > 0 
	-- Has a comma, must be a city state
	begin
		IF @slashpos > 0
		begin
			SELECT @use_dcitystate = 'Y' 
			SELECT @ete_dcity = RTRIM(LTRIM(LEFT(@ete_destcity, @ete_commapos - 1))) 
			SELECT @ete_deststate = RTRIM(LTRIM(SUBSTRING(@ete_destcity, (@ete_commapos + 1), (@slashpos - (@ete_commapos + 1)))))
			SELECT @ls_dcounty = RTRIM(LTRIM(RIGHT(@ete_destcity, (LEN(@ete_destcity) - @slashpos))))
			SELECT @ls_dcounty = SUBSTRING(@ls_dcounty, 1, 3)

			If rtrim(ltrim(isnull(@ls_dcounty, ''))) <> ''
			begin
				SELECT @ete_destcity = @ete_dcity 
				SELECT @ete_destlat = cty_latitude, 
					   @ete_destlong = cty_longitude 
  				  FROM city 
 				 WHERE cty_name = @ete_destcity
				   AND cty_state = @ete_deststate
				   AND cty_county = @ls_dcounty
			end
			else
			begin
				SELECT @ete_destcity = @ete_dcity 
				SELECT @ete_destlat = cty_latitude, 
					   @ete_destlong = cty_longitude 
  				  FROM city 
 				 WHERE cty_name = @ete_destcity
				   AND cty_state = @ete_deststate
			end
		end
		else
		begin
			SELECT @use_dcitystate = 'Y' 
			SELECT @ete_dcity = RTRIM(LTRIM(LEFT(@ete_destcity, @ete_commapos - 1))) 
			SELECT @ete_deststate = RTRIM(LTRIM(SUBSTRING(@ete_destcity, @ete_commapos + 1, 99))) 
			SELECT @ete_destcity = @ete_dcity 
			SELECT @ete_destlat = cty_latitude, 
				   @ete_destlong = cty_longitude 
  			  FROM city 
 			 WHERE cty_name = @ete_destcity
			   AND cty_state = @ete_deststate

		end
	end
		--END PTS 49543 JJF 20091021 
	else
	-- see if we have origin states, zones, or both or see if the value is a city name with no state.
	begin
		--PTS 50115 jjf 20091208 - It's possible for state lists (which aren't comma separated) to match city names (COMO for instance).
		--if exists (select 1 from city where cty_name = ltrim(rtrim(@ete_destcity)))
		--   set @use_dcityonly = 'Y'
		--else
		--END PTS 50115 jjf 20091208 - It's possible for state lists (which aren't comma separated) to match city names (COMO for instance).
		if len(@ete_destcity) > 1 set @chunk = substring(@ete_destcity, 1, 2)
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
		
			If (len(@ete_destcity) -2) >= 0
				set @ete_destcity = right(@ete_destcity, len(@ete_destcity) -2)
			if len(@ete_destcity) > 1 set @chunk = substring(@ete_destcity, 1, 2) else break
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------


-- remove entries that do not fall with in the specified distance from the destination requested by the user
if @use_dcitystate = 'Y' and @ete_destradius > 0
begin
   UPDATE #results 
      SET ete_dhmiles_dest = dbo.tmw_airdistance_fn(@ete_destlat, @ete_destlong, ete_destlatitude, ete_destlongitude)
    WHERE ISNULL(ete_deststate, '') <> ''
   
   delete #results 
    where ete_destlatitude = 0
       or ete_destlongitude = 0	
       or ete_dhmiles_dest > @ete_destradius 		
end
-- remove entries that do not match the destination city and state specified by the usert
if ((@use_dcitystate = 'Y' and @ete_destradius < 1) or @use_dcityonly = 'Y')
   delete #results 
    where (@use_dcitystate = 'Y' and (ltrim(rtrim(isnull(ete_destcity, ''))) <> ltrim(rtrim(isnull(@ete_destcity, '')))
           or ltrim(rtrim(isnull(ete_deststate, ''))) <> ltrim(rtrim(isnull(@ete_deststate, '')))) or @use_dcitystate = 'N')
      and (@use_dcityonly = 'Y' and ltrim(rtrim(isnull(ete_destcity, ''))) <> ltrim(rtrim(@ete_destcity)) or @use_dcityonly = 'N')

--PTS 49543 JJF 20091021 handle ete_deststate fill while city unknown
  delete #results 
    where (ltrim(rtrim(isnull(ete_deststate, ''))) <> ltrim(rtrim(isnull(@ete_deststate, ''))))
     AND (ete_deststate  not in ('', 'XX'))
     AND (rtrim(ltrim(isnull(ete_destcity, 'UNKNOWN'))) = 'UNKNOWN')
--PTS 49543 JJF 20091021 handle ete_deststate fill while city unknown

--PTS 50127 JJF 20091207
--Remove ete entries that have ete_destcity as one or more states
delete #results
where CHARINDEX(',', ete_destcity) = 0
	and CHARINDEX(',' + @ete_deststate + ',', ete_destcitysearch) = 0
	and ete_destcity <> 'UNKNOWN'
	and ete_destcity <> ''
--END PTS 50127 JJF 20091207

If @use_dcitystate = 'N' and @use_dcityonly = 'N' and len(@ete_destcity_orig) > 1  -- Ignore the radius.
-- If they enter a state, return all records with that state in the ete_destcity or ete_deststate field.
-- If they enter a zone, return all possible children in that zone.

begin
	--PTS 50127 JJF 20091207 blank destinations should be included
	update #results
	set dont_delete = 'Y'
	where isnull(ete_destcity, '') = ''
	--PTS 50127 JJF 20091207 blank destinations should be included
	
	-- work through our list of states and save appropriate records.
	set @state = substring(@deststatestouse, 1, 2)	
	While len(@state) > 0 AND @state <> ''
	begin	
		-- Check the ete_destcity field for the state.			
		update #results
		set dont_delete = 'Y'
		where CHARINDEX(',' + @state + ',', ete_destcitysearch) > 0

		-- Check the ete_deststate field for the state.	
		update #results
		set dont_delete = 'Y'
		where ltrim(rtrim(ete_deststate)) = @state

		-- Get next state
		set @deststatestouse = right(@deststatestouse, len(@deststatestouse) -3)
		set @state = substring(@deststatestouse, 1, 2)
	end

	-- Work through our list of zones and save all possible children.
	-- If they enter Z4 - save all records with Z4 in ete_destcity.
	-- Search for all states in Z4 and save all with that state in ete_destcity or ete_deststate. 
	set @zone = substring(@destzonestouse, 1, 2)
	While len(@zone) > 0 
	begin
		-- Check the ete_destcity field for the zone.			
		update #results
		set dont_delete = 'Y'
		where CHARINDEX(',' + @zone + ',', ete_destcitysearch) > 0

		select @state = (select min(tcz_state) from transcore_zones where tcz_zone = @zone)
		While len(@state) > 0 
		begin
			-- Check the ete_destcity field for the state.			
			update #results
			set dont_delete = 'Y'
			where CHARINDEX(',' + @state + ',', ete_destcitysearch) > 0

			-- Check the ete_deststate field for the state.	
			update #results
			set dont_delete = 'Y'
			where ltrim(rtrim(ete_deststate)) = @state

			-- Get next state in that zone
			select @state = (select min(tcz_state) from transcore_zones where tcz_zone = @zone and tcz_state > @state)
		end

		-- Get next zone
		set @destzonestouse = right(@destzonestouse, len(@destzonestouse) -3)
		set @zone = substring(@destzonestouse, 1, 2)
	end

	-- Get rid of all records that are not worthy.
	delete #results where dont_delete <> 'Y'

end


if 	(isnull(@caf_car_type1, '') <> '') 
	or (isnull(@caf_car_type2, '') <> '')
	or (isnull(@caf_car_type3, '') <> '')
	or (isnull(@caf_car_type4, '') <> '')
	or (isnull(@caf_liability_limit, 0) <> 0 )
	or (isnull(@caf_cargo_limit, 0) <> 0) 
	or (isnull(@caf_service_rating, '') <> '') 
 	or (isnull(@caf_ins_cert, 'N') = 'Y')
	or (isnull(@caf_w9, 'N') = 'Y')-- or upper(@caf_w9) = 'N' or @caf_w9 = carrier.car_ins_w9)
	or (isnull(@caf_contract, 'N') = 'Y') --or upper(@caf_contract) = 'N' or @caf_contract = carrier.car_ins_contract)
	or (isnull(@carrier, '') <> '') 
	or (isnull(@trcaccess, '') <> '') 
	or (isnull(@trlaccess, '') <> '') 
	or (isnull(@drvqual, '') <> '') 
	or (isnull(@carqual, '') <> '') 
begin
	-- 37106 BDH.  Passing in each arg instead of the view_id.
	-- -- Carrier filters:
	-- --if isnull(@caf_viewid, '') <> '' and upper(@caf_viewid) <> 'UNK'
	-- --begin
	-- -- 37106 BDH.  Passing in each arg instead of the view_id.
	-- -- 	select  @caf_car_type1 = caf_car_type1,	
	-- -- 			@caf_car_type2 = caf_car_type2,
	-- -- 			@caf_car_type3 = caf_car_type3,
	-- -- 			@caf_car_type4 = caf_car_type4,
	-- -- 			@caf_liability_limit = caf_liability_limit,
	-- -- 			@caf_cargo_limit = caf_cargo_limit, 
	-- -- 			@caf_service_rating = caf_service_rating,
	-- -- 			@caf_ins_cert = caf_ins_cert,
	-- -- 			@caf_w9 = caf_w9,
	-- -- 			@caf_contract = caf_contract,
	-- -- 			--@caf_history_only = caf_history_only, 
	-- -- 			@carrier = caf_carrier 
	-- -- 		from carrierfilter
	-- -- 		where caf_viewid = @caf_viewid

	insert #temp_filteredcarriers (fcr_carrier, keepfromfilter)
		select car_id, 'Y' from carrier 
		where (isnull(@caf_car_type1, '') = '' or @caf_car_type1 = 'UNK' or @caf_car_type1 = carrier.car_type1)
		and (isnull(@caf_car_type2, '') = '' or @caf_car_type2 = 'UNK' or @caf_car_type2 = carrier.car_type2)
		and (isnull(@caf_car_type3, '') = '' or @caf_car_type3 = 'UNK' or @caf_car_type3 = carrier.car_type3)
		and (isnull(@caf_car_type4, '') = '' or @caf_car_type4 = 'UNK' or @caf_car_type4 = carrier.car_type4)
		and (isnull(@caf_liability_limit, 0) = 0 or @caf_liability_limit <= carrier.car_ins_liabilitylimits)
		and (isnull(@caf_cargo_limit, 0) = 0 or @caf_cargo_limit <= carrier.car_ins_cargolimits)
		and (isnull(@caf_service_rating, '') = '' or @caf_service_rating = 'UNK' or @caf_service_rating = carrier.car_rating)
		and (isnull(@caf_ins_cert, '') = '' or upper(@caf_ins_cert) = 'N' or @caf_ins_cert = carrier.car_ins_certificate)
		and (isnull(@caf_w9, '') = '' or upper(@caf_w9) = 'N' or @caf_w9 = carrier.car_ins_w9)
		and (isnull(@caf_contract, '') = '' or upper(@caf_contract) = 'N' or @caf_contract = carrier.car_ins_contract)
		--PTS 44932 JJF 20081118 - external equipment restriction passes Carrier = 'UNKNOWN'
		--and (isnull(@carrier, '') = '' or @carrier = carrier.car_id)	
		and (isnull(@carrier, '') = '' or @carrier = carrier.car_id or @carrier = 'UNKNOWN')
		--END PTS 44932 JJF 20081118 - external equipment restriction passes Carrier = 'UNKNOWN'	

	 --Check trailer accessories
	IF LEN(@trlaccess) > 0 
        BEGIN	
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
	END 
	
	-- Check tractor accessories
	IF LEN(@trcaccess) > 0 
	BEGIN
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
	END

	-- Check driver qualifications
	IF LEN(@drvqual) > 0 
	BEGIN
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
	END		
	
	-- Check carrier qualifications	
	IF LEN(@carqual) > 0 
	BEGIN
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
	END
	
	-- Get rid of anything where the carrier does not match with the filters 
	delete #results where ete_carrierid not in (select fcr_carrier from #temp_filteredcarriers)
end

-- 	select @count = count(0) from carrierfilterlist
-- 		where caf_viewid = @caf_viewid
-- 			and upper(cfl_labeldef) = 'TRLACC'
-- 			and cfl_abbr is not null
-- 			and cfl_abbr <> ''		
-- 	
-- 		if @count > 0 
-- 		begin
-- 			delete from #temp_filteredcarriers
-- 			where fcr_carrier not in (select ta_trailer from trlaccessories 
-- 						  where upper(ta_source) = 'CAR'
-- 						  --and isnull(ta_expire_date, '12-31-2049 23:59') > @stp_departure_dt
-- 						  and ta_type in (select cfl_abbr from carrierfilterlist 
-- 							  	  where caf_viewid = @caf_viewid
-- 								  and upper(cfl_labeldef) = 'TRLACC'))							 
-- 		end
	
-- 		select @count = count(0) from carrierfilterlist
-- 		where caf_viewid = @caf_viewid
-- 			and upper(cfl_labeldef) = 'TRCACC'
-- 			and cfl_abbr is not null
-- 			and cfl_abbr <> ''		
-- 	
-- 		if @count > 0 
-- 		begin
-- 			delete from #temp_filteredcarriers
-- 			where fcr_carrier not in (select tca_tractor from tractoraccesories 
-- 						  where upper(tca_source) = 'CAR'
-- 						  --and isnull(tca_expire_date, '12-31-2049 23:59') > @stp_departure_dt
-- 						  and tca_type in (select cfl_abbr from carrierfilterlist 
-- 							  	  where caf_viewid = @caf_viewid
-- 								  and upper(cfl_labeldef) = 'TRCACC'))							  
-- 		end
	
	
-- 		select @count = count(0) from carrierfilterlist
-- 		where caf_viewid = @caf_viewid
-- 			and upper(cfl_labeldef) = 'DRVACC'
-- 			and cfl_abbr is not null
-- 			and cfl_abbr <> ''		
-- 	
-- 		if @count > 0 
-- 		begin
-- 			delete from #temp_filteredcarriers
-- 			where fcr_carrier not in (select drq_driver from driverqualifications 
-- 						  where upper(drq_source) = 'CAR'
-- 						  --and isnull(drq_expire_date, '12-31-2049 23:59') > @stp_departure_dt
-- 						  and drq_type in (select cfl_abbr from carrierfilterlist 
-- 							  	  where caf_viewid = @caf_viewid
-- 								  and upper(cfl_labeldef) = 'DRVACC'))							  
-- 		end
	
	
-- 		select @count = count(0) from carrierfilterlist
-- 		where caf_viewid = @caf_viewid
-- 			and upper(cfl_labeldef) = 'CARQUAL'
-- 			and cfl_abbr is not null
-- 			and cfl_abbr <> ''		
-- 		
-- 		if @count > 0 
-- 		begin
-- 			delete from #temp_filteredcarriers
-- 			where fcr_carrier not in (select caq_carrier_id from carrierqualifications
-- 						  where /*isnull(caq_expire_date, '12-31-2049 23:59') > @stp_departure_dt
-- 						  and*/ caq_type in (select cfl_abbr from carrierfilterlist 
-- 							  	  where caf_viewid = @caf_viewid
-- 								  and upper(cfl_labeldef) = 'CARQUAL'))							  
-- 		end

	-- Get rid of anything where the carrier does not match with the filters 
	 --delete #results where ete_carrierid not in (select fcr_carrier from #temp_filteredcarriers)
--end
-- 37106 End.


--select * from #temp_filteredcarriers
-- 
SELECT ete_id, 
       ete_postingage, 
       ete_postingdate, 
       ete_availabledate, 
       ete_equipmenttype, 
       ete_loadtype, 
       ete_dhmiles_origin, 
       ete_origcity, 
       ete_origstate, 
       ete_destcity, 
       ete_deststate, 
       ete_dhmiles_dest, 
       ete_carrierid, 
       ete_carriername, 
       ete_carrierstate,
       ete_contactname, 
       ete_contactphone, 
       ete_equipmentlength, 
       ete_loadweight, 
       ete_truckcount, 
       ete_truckid, 
       ete_driver_name, 
       ete_driver_phone, 
       branch_t, 
       branch, 
       ete_source, 
       ete_remarks, 
       ete_expirationdate, 
       ete_status, 
       ete_created, 
       ete_createdby, 
       ete_updated, 
       ete_updatedby, 
       ete_origlatitude, 
       ete_origlongitude, 
       ete_destlatitude, 
       ete_destlongitude,
       cartype1_t,
       cartype2_t,
       cartype3_t,
       cartype4_t,
       car_type1,
       car_type2,
       car_type3,
       car_type4,
	   ete_mc,
	   '...' ete_dest_statelist, -- PTS 45270 - DJM
		--PTS 46005 JJF 20090325
		ete_automatch,
		ete_originradius,
		ete_destradius,
		--END PTS 46005 JJF 20090325
		--PTS 48978 JJF 20090915 
		ete_sourcerefnumber,
		--END PTS 48978 JJF 20090915
		ete_lgh_number
  FROM #results 
order by ete_dhmiles_origin, ete_dhmiles_dest


END

GO
GRANT EXECUTE ON  [dbo].[d_external_equipment] TO [public]
GO
