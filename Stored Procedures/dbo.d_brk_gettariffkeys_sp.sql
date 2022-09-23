SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*   MODIFICATION

MRH Coppied to modify and use for the logistics / brokerage module
q2003	q003
DPETE PTS12047 when multiple indexes apply on a secondary charge the rate pulls multiple times.  Added
	AND trk_number = (Select min(trk_number) FROM tariffkey c
		WHERE c.tar_number = t.tar_number)
  to retrieve for secondary charges

MRH 4/26/2002 Get all of the carriers from the carrier history also. Carrier history does not restrict
by carriers with a tarrif so I might want to only match locations and or companies....

MRH 6/09/2003 This proc is only returning rates for carriers if there is a specific carrier passed in.
 It should return all when the carrier is ''.

06/18/03 BLM	17421	replace getdate with dbo.TMW_GETDATE.
11/12/03 BLM		add cht_currunit
11/13/03 MRH added isnull to the return values.
	 MRH return car_currency
05/04/06 JG 32678 fix recompile problem caused by temp table DDL and DML interleaving
06/24/06 BDH 33184 Incorporate new carrier filter window.
10/3/06  BDH 34777 Return only one carrier if they put a carrier on the filter.
10/9/06  BDH 34777 Changed logic for @temp3 city/state insert to be more robust.
	 Then, if they pass in any of the 4 (cities or states) and want history only, delete from @temp3.
11/19/2007 PTS 38811 JDS:  mod 4 cols from INT  to Dec(19,4)
5/12/08 pts 42689 BDH.  Limit to only those carriers that meet the order's load requirements.
	This corresponds to GI setting = 'IncludeLoadReqsinACS'
06/17/2008  PTS 42887 Performance Edits
7/8/2008 PTS 42689, moved the load requirement check right before the select to generate the return set.  It was
	filtering the carriers that met the load requirements, then added the additional entries for carriers that met
	lane requirements.  It was also ignoring the initial @temp matches that were matched in the first part of the query.
9/17/2008 JLB PTS 44005  add car_type1 to result set
10/8/2008 JET PTS 42738	made some performance enhancements (changed the way the filtered carriers are used and modified some SQL joins.
46503 JLB 4/10/2009		Add cartype_2 - 4 to result set
68760 MTC 6/3/2013 Changed temp tables to table variables to try to reduce chronic recompilation
70196 MTC 06/14/2013 Changed logic around to avoid deletes of temp table data, prevented inserts instead. Added parameterized dyanmic SQL in one place.
*/
CREATE PROC [dbo].[d_brk_gettariffkeys_sp]
	@tarnum int,
	@billdate datetime,
	@billto char(8),
	@ordby char(8),
	@cmptype1 char(6),
	@cmptype2 char(6),
	@trltype1 char(6),
	@trltype2 char(6),
	@trltype3 char(6),
	@trltype4 char(6),
	@revtype1 char(6),
	@revtype2 char(6),
	@revtype3 char(6),
	@revtype4 char(6),
	@cmdcode char(8),
	@cmdclass char(8),
	@originpoint char(8),
	@origincity int,
	@originzip char(10),
	@origincounty char(3),
	@originstate char(6),
	@destpoint char(8),
	@destcity int,
	@destzip char(10),
	@destcounty char(3),
	@deststate char(6),
	@miles int,
	@distunit char(6),
	@odmiles int,
	@odunit char(6),
	@stops int,
	@length money,
	@width money,
	@height money,
	@company char(8),
	@carrier char(8),
	@triptype char(6),
	@loadstat char(6),
	@team char(6),
	@cartype char(6),
	@drvtype1 char(6),
	@drvtype2 char(6),
	@drvtype3 char(6),
	@drvtype4 char(6),
	@trctype1 char(6),
	@trctype2 char(6),
	@trctype3 char(6),
	@trctype4 char(6),
	@itemcode char(6),
    @stoptype char(6),
	@delays char(6),
	@carryins1 int,
	@carryins2 int,
	@ooamileage int,
	@ooastop int ,
	@retrieveby char(1), --'B' billing rates only ,'S' settlement Rates only, anything else All Rates
	@terms char(6),
	@mastercompany char(8),
	@user_id varchar(30),		-- 33184 BDH
	@use_defaults varchar(20),	-- 33184 BDH
	@stp_arrival_dt datetime,	-- 33184 BDH
	@stp_departure_dt datetime,	-- 33184 BDH
	@caf_viewid varchar(6),-- = null		-- 35209 BDH
	@lgh_number int,
	@mov_number int,
	@first_stp_departure_dt datetime,
	@reldate datetime,
	@origin_cmpid CHAR (8), /* 04/30/2009 MDH PTS 46785: Added */			/* 58 */
	@dest_cmpid CHAR (8)	/* 04/30/2009 MDH PTS 46785: Added */			/* 59 */
as

set nocount on
set transaction isolation level read uncommitted

declare @SQL nvarchar(max)

declare @trknumber int,
	@matchloadstat varchar(3),
	@tcarryins1 int,
	@tcarryins2 int,
	@tooamileage int,
	@tooastop int,
	@min_tar_number int,
	@ratematch decimal(9,4),
	@destratestate varchar(6),
	@originratestate varchar(6),
	@count int

-- new for 33184
declare @caf_car_type1 varchar(6),
	@caf_car_type2 varchar(6),
	@caf_car_type3 varchar(6),
	@caf_car_type4 varchar(6),
	@caf_liability_limit money,
	@caf_cargo_limit money,
	@caf_service_rating varchar(6),
	@caf_ins_cert char(1),
	@caf_w9 char(1),
	@caf_contract char(1),
	@caf_history_only char(1)

-- new for 42689
declare @check_loadreqs varchar(60),
	@lrq_id int,
	@lrq_equip_type varchar(20),
	@lrq_not char(1),
	@lrq_type varchar(20),
	@lrq_mandatory char(1),
	@lrq_quantity int,
	@lrq_expire_date datetime,
	@lgh_carrier varchar(8)

IF @carryins1 > 0
  SELECT @tcarryins1 = 1
IF @carryins2 > 0
   SELECT @tcarryins2 = 1
IF @ooamileage > 0
   SELECT @tooamileage = 1
IF @ooastop > 0
   SELECT @tooastop = 1

if @loadstat = 'LD'
   select @matchloadstat = 'UNK'
else
   select @matchloadstat = @loadstat

/* PTS 9554 4/30/01 - Added taa_seq to allow users to control the order Accessorial charges appear
	on an invoice.  No chages made to Settlements.			*/

declare @temp table (trk_number int null,
	tar_number int null,
	trk_billto varchar(8) null,
	trk_orderedby varchar(8) null,
	cmp_othertype1 varchar(6) null,
	cmp_othertype2 varchar(6) null,
	cmd_code varchar(8) null,
	cmd_class varchar(8) null,
	trl_type1 varchar(6) null,
	trl_type2 varchar(6) null,
	trl_type3 varchar(6) null,
	trl_type4 varchar(6) null,
	trk_revtype1 varchar(6) null,
	trk_revtype2 varchar(6) null,
	trk_revtype3 varchar(6) null,
	trk_revtype4 varchar(6) null,
	trk_originpoint varchar(8) null,
	trk_origincity int null,
	trk_originzip varchar(10) null,
	trk_origincounty varchar(3) null,
	trk_originstate varchar(6) null,
	trk_destpoint varchar(8) null,
	trk_destcity int null,
	trk_destzip varchar(10) null,
	trk_destcounty varchar(3) null,
	trk_deststate varchar(6) null,
	trk_duplicateseq int null,
	trk_company varchar(8) null,
	trk_carrier varchar(8) null,
	trk_lghtype1 varchar(6) null,
	trk_load varchar(6) null,
	trk_team varchar(6) null,
	trk_boardcarrier varchar(6) null,
	trk_minmiles int null,
	trk_maxmiles int null,
	trk_distunit varchar(6) null,
	trk_minweight decimal(19,4), 		-- PTS 38811
	trk_maxweight decimal(19,4), 		-- PTS 38811
	--trk_minweight int null,
	--trk_maxweight int null,
	trk_wgtunit varchar(6) null,
	trk_minpieces int null,
	trk_maxpieces int null,
	trk_countunit varchar(6) null,
	trk_minvolume decimal(19,4), 		-- PTS 38811
	trk_maxvolume decimal(19,4), 		-- PTS 38811
	--trk_minvolume int null,
	--trk_maxvolume int null,
	trk_volunit varchar(6) null,
	trk_minodmiles int null,
	trk_maxodmiles int null,
	trk_odunit varchar(6) null,
	mpp_type1 varchar(6) null,
	mpp_type2 varchar(6) null,
	mpp_type3 varchar(6) null,
	mpp_type4 varchar(6) null,
	trc_type1 varchar(6) null,
	trc_type2 varchar(6) null,
	trc_type3 varchar(6) null,
	trc_type4 varchar(6) null,
	cht_itemcode varchar(6) null,
	trk_stoptype varchar(6) null,
	trk_delays varchar(6) null,
	trk_carryins1 int null,
	trk_carryins2 int null,
	trk_ooamileage int null,
	trk_ooastop int null,
	trk_minmaxmiletype tinyint null,
	trk_terms varchar(6) null,
	trk_triptype_or_region char(1) null,
	trk_tt_or_oregion varchar(10) null,
	trk_dregion varchar(10) null,
	cmp_mastercompany varchar(8) null,
	taa_seq int null,
	trk_mileagetable char(1) null,
	trk_fueltableid char(8) null,
	trk_minrevpermile money null,
	trk_maxrevpermile money null,
	cht_currunit varchar(6) null)	-- blm	11.12.03

declare @temp1 table  (
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
	exp_priority2 	int null,
    cartype1_t		varchar(20) NULL,
    cartype2_t		varchar(20) NULL,
    cartype3_t		varchar(20) NULL,
    cartype4_t		varchar(20) NULL,
	car_type1		varchar(6)  NULL,
	car_type2		varchar(6)  NULL,
	car_type3		varchar(6)  NULL,
	car_type4		varchar(6)  NULL
)

declare @temp3 table 
	( Crh_Carrier varchar(8) null)


declare @temp_filteredcarriers table  (fcr_carrier varchar(8))


declare @temp_loadreqs table (
	lrq_id int identity,
	drv1 varchar(8),
	drv1_pri1soon int,
	drv1_pri2soon int,
	drv1_pri1now int,
	drv1_pri2now int,
	drv2 varchar(8),
	drv2_pri1soon int,
	drv2_pri2soon int,
	drv2_pri1now int,
	drv2_pri2now int,
	trc varchar(8),
	trc_pri1soon int,
	trc_pri2soon int,
	trc_pri1now int,
	trc_pri2now int,
	trl1 varchar(13),
	trl1_pri1soon int,
	trl1_pri2soon int,
	trl1_pri1now int,
	trl1_pri2now int,
	trl2 varchar(13),
	trl2_pri1soon int,
	trl2_pri2soon int,
	trl2_pri1now int,
	trl2_pri2now int,
	lrq_equip_type varchar(6),
	lrq_not char(1),
	lrq_type varchar(6),
	lrq_mandatory char(1),
	requirement varchar(80),
	asgn_id varchar(13),
	car varchar(8),
	car_pri1soon int,
	car_pri2soon int,
	car_pri1now int,
	car_pri2now int,
	lrq_quantity int,
	lrq_availqty int,
	lrq_inventory_item char(1),
	lrq_expire_date datetime,
	lgh_enddate datetime,
	lgh_startdate datetime,
	chassis varchar(13),
	chassis_pri1soon integer,
	chassis_pri2soon integer,
	chassis_pri1now integer,
	chassis_pri2now integer,
	chassis2 varchar(13),
	chassis2_pri1soon integer,
	chassis2_pri2soon integer,
	chassis2_pri1now integer,
	chassis2_pri2now integer,
	dolly varchar(13),
	dolly_pri1soon integer,
	dolly_pri2soon integer,
	dolly_pri1now integer,
	dolly_pri2now integer,
	dolly2 varchar(13),
	dolly2_pri1soon integer,
	dolly2_pri2soon integer,
	dolly2_pri1now integer,
	dolly2_pri2now integer,
	trailer3 varchar(13),
	trailer3_pri1soon integer,
	trailer3_pri2soon integer,
	trailer3_pri1now integer,
	trailer3_pri2now integer,
	trailer4 varchar(13),
	trailer4_pri1soon integer,
	trailer4_pri2soon integer,
	trailer4_pri1now integer,
	trailer4_pri2now integer,
	def_id_type varchar(6))


--******************************

-- BDH 42689.  If there is already a carrier assigned to the load, only return that carrier in ACS.
if isnull(@lgh_number, 0) > 0
begin
	set @lgh_carrier = (select lgh_carrier from legheader where lgh_number = @lgh_number)
	if isnull(@lgh_carrier, 'UNKNOWN') <> 'UNKNOWN'
		set @carrier = @lgh_carrier
end
-- 42689 end



-- BDH 35209 We can get here either by opening the ACS window or the External Equip tab on the planning worksheet.
-- If we come into the ACS window directly, use the userid for the carrierfilters.
-- If we come from the pln wksheet, use the carrier filter view used in that window.

if len(isnull(@caf_viewid, '')) > 0 or upper(@caf_viewid) = 'UNK'
begin  -- comming from external equip tab on planning worksheet use caf_viewid

	select  @caf_car_type1 = caf_car_type1,
			@caf_car_type2 = caf_car_type2,
			@caf_car_type3 = caf_car_type3,
			@caf_car_type4 = caf_car_type4,
			@caf_liability_limit = caf_liability_limit,
			@caf_cargo_limit = caf_cargo_limit,
			@caf_service_rating = caf_service_rating,
			@caf_ins_cert = caf_ins_cert,
			@caf_w9 = caf_w9,
			@caf_contract = caf_contract,
			--@caf_history_only = caf_history_only,
			@carrier = caf_carrier
		from carrierfilter
		where caf_viewid = @caf_viewid


select @SQL = N'select car_id from carrier with (nolock) where '

if not (@caf_car_type1 is null or @caf_car_type1 = '')
	select @SQL = @SQL + N'@caf_car_type1 = carrier.car_type1 and '

if not (@caf_car_type2 is null or @caf_car_type2 = '')
	select @SQL = @SQL + N'@caf_car_type2 = carrier.car_type2 and '

if not (@caf_car_type3 is null or @caf_car_type3 = '')
	select @SQL = @SQL + N'@caf_car_type3 = carrier.car_type3 and '

if not (@caf_car_type4 is null or @caf_car_type4 = '')
	select @SQL = @SQL + N'@caf_car_type4 = carrier.car_type4 and '

if not (@caf_liability_limit is null or @caf_liability_limit = 0)
	select @SQL = @SQL + N'@caf_liability_limit <= carrier.car_ins_liabilitylimits and '

if not (@caf_cargo_limit is null or @caf_cargo_limit = 0)
	select @SQL = @SQL + N'@caf_cargo_limit <= carrier.car_ins_cargolimits and '

if not (@caf_service_rating is null or @caf_service_rating = '')
	select @SQL = @SQL + N'@caf_service_rating in (''UNK'', ''UNKNOWN'', carrier.car_rating) and '

if not (@caf_ins_cert is null or @caf_ins_cert = '' or @caf_ins_cert = 'N')
	select @SQL = @SQL + N'@caf_ins_cert = carrier.car_ins_certificate and '

if not (@caf_w9 is null or @caf_w9 = '' or @caf_w9 = 'N')
	select @SQL = @SQL + N'@caf_w9 = carrier.car_ins_w9 and '

if not (@caf_contract is null or @caf_contract = '' or @caf_contract = 'N')
	select @SQL = @SQL + N'@caf_contract = carrier.car_ins_contract and '

if not (@carrier is null or @carrier = '')
	select @SQL = @SQL + N'@carrier = carrier.car_id and '

--final, seals the stmt with no AND at the end.
	select @SQL = @SQL + N'car_status <> ''OUT'''

	insert @temp_filteredcarriers
		exec sp_executeSQL @SQL, 
		@params=N'@caf_car_type1 varchar(6), @caf_car_type2 varchar(6), @caf_car_type3 varchar(6), @caf_car_type4 varchar(6),
		@caf_liability_limit money, @caf_cargo_limit money, @caf_service_rating varchar(6),  @caf_ins_cert char(1), @caf_w9 char(1),
		@caf_contract char(1), @carrier char(8)',@caf_car_type1=@caf_car_type1, @caf_car_type2=@caf_car_type2, 
		@caf_car_type3=@caf_car_type3, @caf_car_type4 =@caf_car_type4,@caf_liability_limit=@caf_liability_limit, 
		@caf_cargo_limit =@caf_cargo_limit, @caf_service_rating=@caf_service_rating,  @caf_ins_cert=@caf_ins_cert, 
		@caf_w9=@caf_w9,@caf_contract=@caf_contract, @carrier=@carrier;

		        
	select @count = count(0) from carrierfilterlist
		where caf_viewid = @caf_viewid
			and upper(cfl_labeldef) = 'TRLACC'
			and cfl_abbr is not null
			and cfl_abbr <> ''

		if @count > 0
		begin
			delete from @temp_filteredcarriers
			where fcr_carrier not in (select ta_trailer from trlaccessories
						  where upper(ta_source) = 'CAR'
						  --and isnull(ta_expire_date, '12-31-2049 23:59') > @stp_departure_dt
						  and ta_type in (select cfl_abbr from carrierfilterlist
							  	  where caf_viewid = @caf_viewid
								  and upper(cfl_labeldef) = 'TRLACC'))
		END
        
		select @count = count(0) from carrierfilterlist
		where caf_viewid = @caf_viewid
			and upper(cfl_labeldef) = 'TRCACC'
			and cfl_abbr is not null
			and cfl_abbr <> ''

		if @count > 0
		begin
			delete from @temp_filteredcarriers
			where fcr_carrier not in (select tca_tractor from tractoraccesories
						  where upper(tca_source) = 'CAR'
						  --and isnull(tca_expire_date, '12-31-2049 23:59') > @stp_departure_dt
						  and tca_type in (select cfl_abbr from carrierfilterlist
							  	  where caf_viewid = @caf_viewid
								  and upper(cfl_labeldef) = 'TRCACC'))
		end

		select @count = count(0) from carrierfilterlist
		where caf_viewid = @caf_viewid
			and upper(cfl_labeldef) = 'DRVACC'
			and cfl_abbr is not null
			and cfl_abbr <> ''

		if @count > 0
		begin
			delete from @temp_filteredcarriers
			where fcr_carrier not in (select drq_driver from driverqualifications
						  where upper(drq_source) = 'CAR'
						  --and isnull(drq_expire_date, '12-31-2049 23:59') > @stp_departure_dt
						  and drq_type in (select cfl_abbr from carrierfilterlist
							  	  where caf_viewid = @caf_viewid
								  and upper(cfl_labeldef) = 'DRVACC'))
		end

		select @count = count(0) from carrierfilterlist
		where caf_viewid = @caf_viewid
			and upper(cfl_labeldef) = 'CARQUAL'
			and cfl_abbr is not null
			and cfl_abbr <> ''

		if @count > 0
		begin
			delete from @temp_filteredcarriers
			where fcr_carrier not in (select caq_carrier_id from carrierqualifications
						  where /*isnull(caq_expire_date, '12-31-2049 23:59') > @stp_departure_dt
						  and*/ caq_type in (select cfl_abbr from carrierfilterlist
							  	  where caf_viewid = @caf_viewid
								  and upper(cfl_labeldef) = 'CARQUAL'))
		end

		end
else  -- Opening ACS window directly, use userid
begin
	if @use_defaults = 'defaults'
	begin
		select  @caf_car_type1 = caf_car_type1 from carrierfilter where caf_userid = @user_id and upper(caf_car_type1_def) = 'Y'
		select  @caf_car_type2 = caf_car_type2 from carrierfilter where caf_userid = @user_id and upper(caf_car_type2_def) = 'Y'
		select  @caf_car_type3 = caf_car_type3 from carrierfilter where caf_userid = @user_id and upper(caf_car_type3_def) = 'Y'
		select  @caf_car_type4 = caf_car_type4 from carrierfilter where caf_userid = @user_id and upper(caf_car_type4_def) = 'Y'
		select  @caf_liability_limit = caf_liability_limit from carrierfilter where caf_userid = @user_id and upper(caf_liability_limit_def) = 'Y'
		select  @caf_cargo_limit = caf_cargo_limit from carrierfilter where caf_userid = @user_id and upper(caf_cargo_limit_def) = 'Y'
		select  @caf_service_rating = caf_service_rating from carrierfilter where caf_userid = @user_id and upper(caf_service_rating_def) = 'Y'
		select  @caf_ins_cert = caf_ins_cert from carrierfilter where caf_userid = @user_id and upper(caf_ins_cert_def) = 'Y'
		select  @caf_w9 = caf_w9 from carrierfilter where caf_userid = @user_id and upper(caf_w9_def) = 'Y'
		select  @caf_contract = caf_contract from carrierfilter where caf_userid = @user_id and upper(caf_contract_def) = 'Y'
		select  @caf_history_only = caf_history_only from carrierfilter where caf_userid = @user_id and upper(caf_history_only_def) = 'Y'
		select  @carrier = caf_carrier from carrierfilter where caf_userid = @user_id and upper(caf_carrier_def) = 'Y'


--2nd place this happens
/*
		insert @temp_filteredcarriers
			select car_id from carrier
				where  (isnull(@caf_car_type1, '') = '' or @caf_car_type1 = carrier.car_type1)
				and (isnull(@caf_car_type2, '') = '' or @caf_car_type2 = carrier.car_type2)
				and (isnull(@caf_car_type3, '') = '' or @caf_car_type3 = carrier.car_type3)
				and (isnull(@caf_car_type4, '') = '' or @caf_car_type4 = carrier.car_type4)
				and (isnull(@caf_liability_limit, 0) = 0 or @caf_liability_limit <= carrier.car_ins_liabilitylimits)
				and (isnull(@caf_cargo_limit, 0) = 0 or @caf_cargo_limit <= carrier.car_ins_cargolimits)
				--and (isnull(@caf_service_rating, '') = '' or @caf_service_rating = carrier.car_rating)
				and (isnull(@caf_service_rating, '') = '' or @caf_service_rating in ('UNK', 'UNKNOWN', carrier.car_rating))
				and (isnull(@caf_ins_cert, '') = '' or upper(@caf_ins_cert) = 'N' or @caf_ins_cert = carrier.car_ins_certificate)
				and (isnull(@caf_w9, '') = '' or upper(@caf_w9) = 'N' or @caf_w9 = carrier.car_ins_w9)
				and (isnull(@caf_contract, '') = '' or upper(@caf_contract) = 'N' or @caf_contract = carrier.car_ins_contract)
				and (isnull(@carrier, '') = '' or @carrier = carrier.car_id)  -- 34777 BDH 10/3/06
*/
select @SQL = N'select car_id from carrier with (nolock) where '

if not (@caf_car_type1 is null or @caf_car_type1 = '')
	select @SQL = @SQL + N'@caf_car_type1 = carrier.car_type1 and '

if not (@caf_car_type2 is null or @caf_car_type2 = '')
	select @SQL = @SQL + N'@caf_car_type2 = carrier.car_type2 and '

if not (@caf_car_type3 is null or @caf_car_type3 = '')
	select @SQL = @SQL + N'@caf_car_type3 = carrier.car_type3 and '

if not (@caf_car_type4 is null or @caf_car_type4 = '')
	select @SQL = @SQL + N'@caf_car_type4 = carrier.car_type4 and '

if not (@caf_liability_limit is null or @caf_liability_limit = 0)
	select @SQL = @SQL + N'@caf_liability_limit <= carrier.car_ins_liabilitylimits and '

if not (@caf_cargo_limit is null or @caf_cargo_limit = 0)
	select @SQL = @SQL + N'@caf_cargo_limit <= carrier.car_ins_cargolimits and '

if not (@caf_service_rating is null or @caf_service_rating = '')
	select @SQL = @SQL + N'@caf_service_rating in (''UNK'', ''UNKNOWN'', carrier.car_rating) and '

if not (@caf_ins_cert is null or @caf_ins_cert = '' or @caf_ins_cert = 'N')
	select @SQL = @SQL + N'@caf_ins_cert = carrier.car_ins_certificate and '

if not (@caf_w9 is null or @caf_w9 = '' or @caf_w9 = 'N')
	select @SQL = @SQL + N'@caf_w9 = carrier.car_ins_w9 and '

if not (@caf_contract is null or @caf_contract = '' or @caf_contract = 'N')
	select @SQL = @SQL + N'@caf_contract = carrier.car_ins_contract and '

if not (@carrier is null or @carrier = '')
	select @SQL = @SQL + N'@carrier = carrier.car_id and '

--final, seals the stmt with no AND at the end.
	select @SQL = @SQL + N'car_status <> ''OUT'''

	insert @temp_filteredcarriers
		exec sp_executeSQL @SQL, 
		@params=N'@caf_car_type1 varchar(6), @caf_car_type2 varchar(6), @caf_car_type3 varchar(6), @caf_car_type4 varchar(6),
		@caf_liability_limit money, @caf_cargo_limit money, @caf_service_rating varchar(6),  @caf_ins_cert char(1), @caf_w9 char(1),
		@caf_contract char(1), @carrier char(8)',@caf_car_type1=@caf_car_type1, @caf_car_type2=@caf_car_type2, 
		@caf_car_type3=@caf_car_type3, @caf_car_type4 =@caf_car_type4,@caf_liability_limit=@caf_liability_limit, 
		@caf_cargo_limit =@caf_cargo_limit, @caf_service_rating=@caf_service_rating,  @caf_ins_cert=@caf_ins_cert, 
		@caf_w9=@caf_w9,@caf_contract=@caf_contract, @carrier=@carrier;

		select @count = count(0) from carrierfilterlist
		where cfl_userid = @user_id
			and upper(cfl_labeldef) = 'TRLACC'
			and cfl_abbr is not null
			and cfl_abbr <> ''
			and upper(cfl_default) = 'Y'

		if @count > 0
		begin
			delete from @temp_filteredcarriers
			where fcr_carrier not in (select ta_trailer from trlaccessories
						  where upper(ta_source) = 'CAR'
						  and isnull(ta_expire_date, '12-31-2049 23:59') > @stp_departure_dt
						  and ta_type in (select cfl_abbr from carrierfilterlist
							  	  where cfl_userid = @user_id
								  and upper(cfl_labeldef) = 'TRLACC'
								  and upper(cfl_default) = 'Y'))
		end

		select @count = count(0) from carrierfilterlist
		where cfl_userid = @user_id
			and upper(cfl_labeldef) = 'TRCACC'
			and cfl_abbr is not null
			and cfl_abbr <> ''
			and upper(cfl_default) = 'Y'

		if @count > 0
		begin
			delete from @temp_filteredcarriers
			where fcr_carrier not in (select tca_tractor from tractoraccesories
						  where upper(tca_source) = 'CAR'
						  and isnull(tca_expire_date, '12-31-2049 23:59') > @stp_departure_dt
						  and tca_type in (select cfl_abbr from carrierfilterlist
							  	  where cfl_userid = @user_id
								  and upper(cfl_labeldef) = 'TRCACC'
								  and upper(cfl_default) = 'Y'))
		end
		

		select @count = count(0) from carrierfilterlist
		where cfl_userid = @user_id
			and upper(cfl_labeldef) = 'DRVACC'
			and cfl_abbr is not null
			and cfl_abbr <> ''
			and upper(cfl_default) = 'Y'

		if @count > 0
		begin
			delete from @temp_filteredcarriers
			where fcr_carrier not in (select drq_driver from driverqualifications
						  where upper(drq_source) = 'CAR'
						  and isnull(drq_expire_date, '12-31-2049 23:59') > @stp_departure_dt
						  and drq_type in (select cfl_abbr from carrierfilterlist
							  	  where cfl_userid = @user_id
								  and upper(cfl_labeldef) = 'DRVACC'
								  and upper(cfl_default) = 'Y'))
		end

		

		select @count = count(0) from carrierfilterlist
		where cfl_userid = @user_id
			and upper(cfl_labeldef) = 'CARQUAL'
			and cfl_abbr is not null
			and cfl_abbr <> ''
			and upper(cfl_default) = 'Y'

		if @count > 0
		begin
			delete from @temp_filteredcarriers
			where fcr_carrier not in (select caq_carrier_id from carrierqualifications
						  where isnull(caq_expire_date, '12-31-2049 23:59') > @stp_departure_dt
						  and caq_type in (select cfl_abbr from carrierfilterlist
							  	  where cfl_userid = @user_id
								  and upper(cfl_labeldef) = 'CARQUAL'
								  and upper(cfl_default) = 'Y'))
		END
       
	end
	else
	begin
		select  @caf_car_type1 = caf_car_type1,
			@caf_car_type2 = caf_car_type2,
			@caf_car_type3 = caf_car_type3,
			@caf_car_type4 = caf_car_type4,
			@caf_liability_limit = caf_liability_limit,
			@caf_cargo_limit = caf_cargo_limit,
			@caf_service_rating = caf_service_rating,
			@caf_ins_cert = caf_ins_cert,
			@caf_w9 = caf_w9,
			@caf_contract = caf_contract,
			@caf_history_only = caf_history_only,
			@carrier = caf_carrier
		from carrierfilter
		where caf_userid = @user_id

--3rd place...
/*
		insert @temp_filteredcarriers
		select car_id from carrier
		where (isnull(@caf_car_type1, '') = '' or @caf_car_type1 = carrier.car_type1)
		and (isnull(@caf_car_type2, '') = '' or @caf_car_type2 = carrier.car_type2)
		and (isnull(@caf_car_type3, '') = '' or @caf_car_type3 = carrier.car_type3)
		and (isnull(@caf_car_type4, '') = '' or @caf_car_type4 = carrier.car_type4)
		and (isnull(@caf_liability_limit, 0) = 0 or @caf_liability_limit <= carrier.car_ins_liabilitylimits)
		and (isnull(@caf_cargo_limit, 0) = 0 or @caf_cargo_limit <= carrier.car_ins_cargolimits)
		--and (isnull(@caf_service_rating, '') = '' or @caf_service_rating = carrier.car_rating)
		and (isnull(@caf_service_rating, '') = '' or @caf_service_rating in ('UNK', 'UNKNOWN', carrier.car_rating))
		and (isnull(@caf_ins_cert, '') = '' or upper(@caf_ins_cert) = 'N' or @caf_ins_cert = carrier.car_ins_certificate)
		and (isnull(@caf_w9, '') = '' or upper(@caf_w9) = 'N' or @caf_w9 = carrier.car_ins_w9)
		and (isnull(@caf_contract, '') = '' or upper(@caf_contract) = 'N' or @caf_contract = carrier.car_ins_contract)
		and (isnull(@carrier, '') = '' or @carrier = carrier.car_id)  -- 34777 BDH 10/3/06
		and car_status <> 'OUT'  --JLB PTS 43941
*/
select @SQL = N'select car_id from carrier with (nolock) where '

if not (@caf_car_type1 is null or @caf_car_type1 = '')
	select @SQL = @SQL + N'@caf_car_type1 = carrier.car_type1 and '

if not (@caf_car_type2 is null or @caf_car_type2 = '')
	select @SQL = @SQL + N'@caf_car_type2 = carrier.car_type2 and '

if not (@caf_car_type3 is null or @caf_car_type3 = '')
	select @SQL = @SQL + N'@caf_car_type3 = carrier.car_type3 and '

if not (@caf_car_type4 is null or @caf_car_type4 = '')
	select @SQL = @SQL + N'@caf_car_type4 = carrier.car_type4 and '

if not (@caf_liability_limit is null or @caf_liability_limit = 0)
	select @SQL = @SQL + N'@caf_liability_limit <= carrier.car_ins_liabilitylimits and '

if not (@caf_cargo_limit is null or @caf_cargo_limit = 0)
	select @SQL = @SQL + N'@caf_cargo_limit <= carrier.car_ins_cargolimits and '

if not (@caf_service_rating is null or @caf_service_rating = '')
	select @SQL = @SQL + N'@caf_service_rating in (''UNK'', ''UNKNOWN'', carrier.car_rating) and '

if not (@caf_ins_cert is null or @caf_ins_cert = '' or @caf_ins_cert = 'N')
	select @SQL = @SQL + N'@caf_ins_cert = carrier.car_ins_certificate and '

if not (@caf_w9 is null or @caf_w9 = '' or @caf_w9 = 'N')
	select @SQL = @SQL + N'@caf_w9 = carrier.car_ins_w9 and '

if not (@caf_contract is null or @caf_contract = '' or @caf_contract = 'N')
	select @SQL = @SQL + N'@caf_contract = carrier.car_ins_contract and '

if not (@carrier is null or @carrier = '')
	select @SQL = @SQL + N'@carrier = carrier.car_id and '

--final, seals the stmt with no AND at the end.
	select @SQL = @SQL + N'car_status <> ''OUT'''

	insert @temp_filteredcarriers
		exec sp_executeSQL @SQL, 
		@params=N'@caf_car_type1 varchar(6), @caf_car_type2 varchar(6), @caf_car_type3 varchar(6), @caf_car_type4 varchar(6),
		@caf_liability_limit money, @caf_cargo_limit money, @caf_service_rating varchar(6),  @caf_ins_cert char(1), @caf_w9 char(1),
		@caf_contract char(1), @carrier char(8)',@caf_car_type1=@caf_car_type1, @caf_car_type2=@caf_car_type2, 
		@caf_car_type3=@caf_car_type3, @caf_car_type4 =@caf_car_type4,@caf_liability_limit=@caf_liability_limit, 
		@caf_cargo_limit =@caf_cargo_limit, @caf_service_rating=@caf_service_rating,  @caf_ins_cert=@caf_ins_cert, 
		@caf_w9=@caf_w9,@caf_contract=@caf_contract, @carrier=@carrier;

	

		select @count = count(0) from carrierfilterlist
		where cfl_userid = @user_id
			and upper(cfl_labeldef) = 'TRLACC'
			and cfl_abbr is not null
			and cfl_abbr <> ''

		if @count > 0
		begin
			delete from @temp_filteredcarriers
			where fcr_carrier not in (select ta_trailer from trlaccessories
						  where upper(ta_source) = 'CAR'
						  and isnull(ta_expire_date, '12-31-2049 23:59') > @stp_departure_dt
						  and ta_type in (select cfl_abbr from carrierfilterlist
							  	  where cfl_userid = @user_id
								  and upper(cfl_labeldef) = 'TRLACC'))
		end
		

		select @count = count(0) from carrierfilterlist
		where cfl_userid = @user_id
			and upper(cfl_labeldef) = 'TRCACC'
			and cfl_abbr is not null
			and cfl_abbr <> ''

		if @count > 0
		begin
			delete from @temp_filteredcarriers
			where fcr_carrier not in (select tca_tractor from tractoraccesories
						  where upper(tca_source) = 'CAR'
						  and isnull(tca_expire_date, '12-31-2049 23:59') > @stp_departure_dt
						  and tca_type in (select cfl_abbr from carrierfilterlist
							  	  where cfl_userid = @user_id
								  and upper(cfl_labeldef) = 'TRCACC'))
		end
		

		select @count = count(0) from carrierfilterlist
		where cfl_userid = @user_id
			and upper(cfl_labeldef) = 'DRVACC'
			and cfl_abbr is not null
			and cfl_abbr <> ''

		if @count > 0
		begin
			delete from @temp_filteredcarriers
			where fcr_carrier not in (select drq_driver from driverqualifications
						  where upper(drq_source) = 'CAR'
						  and isnull(drq_expire_date, '12-31-2049 23:59') > @stp_departure_dt
						  and drq_type in (select cfl_abbr from carrierfilterlist
							  	  where cfl_userid = @user_id
								  and upper(cfl_labeldef) = 'DRVACC'))
		end
		

		select @count = count(0) from carrierfilterlist
		where cfl_userid = @user_id
			and upper(cfl_labeldef) = 'CARQUAL'
			and cfl_abbr is not null
			and cfl_abbr <> ''

		if @count > 0
		begin
			delete from @temp_filteredcarriers
			where fcr_carrier not in (select caq_carrier_id from carrierqualifications
						  where isnull(caq_expire_date, '12-31-2049 23:59') > @stp_departure_dt
						  and caq_type in (select cfl_abbr from carrierfilterlist
							  	  where cfl_userid = @user_id
								  and upper(cfl_labeldef) = 'CARQUAL'))
		end
		
	end
end

IF @Carrier <> ''
BEGIN
	-- Get secondary key/s for billing
	-- DEBUG: print 'Get secondary key/s for billing'
	IF @tarnum > 0
	BEGIN
		-- DEBUG: print '@tarnum > 0 (' + CAST (@tarnum AS varchar (5)) + ')'
		insert into @temp
			select t.trk_number,
					t.tar_number,
					t.trk_billto,
					t.trk_orderedby,
					t.cmp_othertype1,
					t.cmp_othertype2,
					t.cmd_code,
					t.cmd_class,
					t.trl_type1,
					t.trl_type2,
					t.trl_type3,
					t.trl_type4,
					t.trk_revtype1,
					t.trk_revtype2,
					t.trk_revtype3,
					t.trk_revtype4,
					t.trk_originpoint,
					t.trk_origincity,
					t.trk_originzip,
					t.trk_origincounty,
					t.trk_originstate,
					t.trk_destpoint,
					t.trk_destcity,
					t.trk_destzip,
					t.trk_destcounty,
					t.trk_deststate,
					t.trk_duplicateseq,
					t.trk_company,
					t.trk_carrier,
					t.trk_lghtype1,
					t.trk_load,
					t.trk_team,
					t.trk_boardcarrier,
					t.trk_minmiles,
					t.trk_maxmiles,
					t.trk_distunit,
					t.trk_minweight,
					t.trk_maxweight,
					t.trk_wgtunit,
					t.trk_minpieces,
 					t.trk_maxpieces,
					t.trk_countunit,
					t.trk_minvolume,
					t.trk_maxvolume,
					t.trk_volunit,
					t.trk_minodmiles,
					t.trk_maxodmiles,
					t.trk_odunit,
					t.mpp_type1,
					t.mpp_type2,
					t.mpp_type3,
					t.mpp_type4,
					t.trc_type1,
					t.trc_type2,
					t.trc_type3,
					t.trc_type4,
					t.cht_itemcode,
					t.trk_stoptype,
					t.trk_delays,
					t.trk_carryins1,
					t.trk_carryins2,
					t.trk_ooamileage,
					t.trk_ooastop ,
					t.trk_minmaxmiletype,
					t.trk_terms,
					t.trk_triptype_or_region,
					t.trk_tt_or_oregion,
					t.trk_dregion,
					t.cmp_mastercompany,
					(select isNull(a.taa_seq,0)
					 from 	tariffaccessorial a
					 where	a.tar_number = @tarnum AND
						a.trk_number = t.trk_number),
					trk_mileagetable,
					trk_fueltableid,
					t.trk_minrevpermile,
					t.trk_maxrevpermile,
					(select cht_currunit from tariffheader where tariffheader.tar_number = t.tar_number)  cht_currunit -- blm	11.12.03
			from tariffkey t
		    where t.trk_startdate <= @billdate AND
					t.trk_enddate >= @billdate AND
					t.trk_minstops <= @stops AND
					t.trk_maxstops >= @stops AND
					t.trk_minlength <= @length AND
					t.trk_maxlength >= @length AND
					t.trk_minwidth <= @width AND
					t.trk_maxwidth >= @width AND
					t.trk_minheight <= @height AND
					t.trk_maxheight >= @height AND
					t.trk_billto in (@billto, 'UNKNOWN') AND
					t.trk_orderedby in (@ordby, 'UNKNOWN') AND
					t.cmp_othertype1 in (@cmptype1, 'UNK') AND
					t.cmp_othertype2 in (@cmptype2, 'UNK') AND
					t.cmd_code in (@cmdcode, 'UNKNOWN') AND
					t.cmd_class in (@cmdclass, 'UNKNOWN') AND
					t.trl_type1 in (@trltype1, 'UNK') AND
					t.trl_type2 in (@trltype2, 'UNK') AND
					t.trl_type3 in (@trltype3, 'UNK') AND
					t.trl_type4 in (@trltype4, 'UNK') AND
					t.trk_revtype1 in (@revtype1, 'UNK') AND
					t.trk_revtype2 in (@revtype2, 'UNK') AND
					t.trk_revtype3 in (@revtype3, 'UNK') AND
					t.trk_revtype4 in (@revtype4, 'UNK') AND
					t.trk_originpoint in (@originpoint, 'UNKNOWN') AND
					t.trk_origincity in (@origincity, 0 ) AND
					t.trk_originzip in (@originzip, 'UNKNOWN') AND
					t.trk_origincounty in (@origincounty, 'UNK') AND
					t.trk_originstate in (@originstate, 'XX') AND
					t.trk_destpoint in (@destpoint, 'UNKNOWN') AND
					t.trk_destcity in (@destcity, 0) AND
					t.trk_destzip in (@destzip, 'UNKNOWN') AND
					t.trk_destcounty in (@destcounty, 'UNK') AND
					t.trk_deststate in (@deststate, 'XX') AND
					t.trk_primary <> 'Y' AND
					t.trk_company in (@company, 'UNK') AND
					t.trk_carrier in (@carrier, 'UNKNOWN') AND
					t.trk_lghtype1 in (@triptype, 'UNK') AND
					t.trk_load in (@loadstat, @matchloadstat) AND
					t.trk_team in (@team, 'UNK') AND
					t.trk_boardcarrier in (@cartype, 'UNK') AND
					t.tar_number in (select b.tar_number
							from 	tariffkey b
							where 	trk_number in
								(select a.trk_number
								 from 	tariffaccessorial a
								 where	a.tar_number = @tarnum)) AND
					IsNull(t.mpp_type1,'UNK') in (@drvtype1, 'UNK') AND
					IsNull(t.mpp_type2,'UNK') in (@drvtype2, 'UNK') AND
					IsNull(t.mpp_type3,'UNK') in (@drvtype3, 'UNK') AND
					IsNull(t.mpp_type4,'UNK') in (@drvtype4, 'UNK') AND
					IsNull(t.trc_type1,'UNK') in (@trctype1, 'UNK') AND
					IsNull(t.trc_type2,'UNK') in (@trctype2, 'UNK') AND
					IsNull(t.trc_type3,'UNK') in (@trctype3, 'UNK') AND
					IsNull(t.trc_type4,'UNK') in (@trctype4, 'UNK') AND
					IsNull(t.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
					ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
					ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
					ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
					ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
					ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
					ISNULL(t.trk_ooastop , 0) in (@tooastop, 0) and
					ISNULL(t.trk_terms , 'UNK') in (@terms, 'UNK') and
					ISNULL(t.cmp_mastercompany, 'UNKNOWN') in (@mastercompany, 'UNKNOWN')
					AND t.trk_number = (Select min(trk_number) FROM tariffkey c
						WHERE c.tar_number = t.tar_number)
	END
	ELSE IF @tarnum < 0  -- Get secondary key/s for settlements
	BEGIN
		-- DEBUG: print '@tarnum < 0 (' + CAST (@tarnum AS varchar (5)) + ')'
		select @tarnum = -@tarnum

		insert into @temp
			select t.trk_number,
					t.tar_number,
					t.trk_billto,
					t.trk_orderedby,
					t.cmp_othertype1,
					t.cmp_othertype2,
					t.cmd_code,
					t.cmd_class,
					t.trl_type1,
					t.trl_type2,
					t.trl_type3,
					t.trl_type4,
					t.trk_revtype1,
					t.trk_revtype2,
					t.trk_revtype3,
					t.trk_revtype4,
					t.trk_originpoint,
					t.trk_origincity,
					t.trk_originzip,
					t.trk_origincounty,
					t.trk_originstate,
					t.trk_destpoint,
					t.trk_destcity,
					t.trk_destzip,
					t.trk_destcounty,
					t.trk_deststate,
					t.trk_duplicateseq,
					t.trk_company,
					t.trk_carrier,
					t.trk_lghtype1,
					t.trk_load,
					t.trk_team,
					t.trk_boardcarrier,
					t.trk_minmiles,
					t.trk_maxmiles,
					t.trk_distunit,
					t.trk_minweight,
					t.trk_maxweight,
					t.trk_wgtunit,
					t.trk_minpieces,
 					t.trk_maxpieces,
					t.trk_countunit,
					t.trk_minvolume,
					t.trk_maxvolume,
					t.trk_volunit,
					t.trk_minodmiles,
					t.trk_maxodmiles,
					t.trk_odunit,
					t.mpp_type1,
					t.mpp_type2,
					t.mpp_type3,
					t.mpp_type4,
					t.trc_type1,
					t.trc_type2,
					t.trc_type3,
					t.trc_type4,
					t.cht_itemcode,
					t.trk_stoptype,
					t.trk_delays,
					t.trk_carryins1,
					t.trk_carryins2,
					t.trk_ooamileage,
					t.trk_ooastop ,
					t.trk_minmaxmiletype,
					t.trk_terms,
					t.trk_triptype_or_region,
					t.trk_tt_or_oregion,
					t.trk_dregion,
					t.cmp_mastercompany,
					0,
					'0',
					'',
					t.trk_minrevpermile,
					t.trk_maxrevpermile,
					(select cht_currunit from tariffheader where tariffheader.tar_number = t.tar_number) cht_currunit -- blm	11.12.03
			FROM tariffkey t
 		    WHERE t.trk_startdate <= @billdate AND
					t.trk_enddate >= @billdate AND
					t.trk_minstops <= @stops AND
					t.trk_maxstops >= @stops AND
					t.trk_minlength <= @length AND
					t.trk_maxlength >= @length AND
					t.trk_minwidth <= @width AND
					t.trk_maxwidth >= @width AND
					t.trk_minheight <= @height AND
					t.trk_maxheight >= @height AND
					t.trk_billto in (@billto, 'UNKNOWN') AND
					t.trk_orderedby in (@ordby, 'UNKNOWN') AND
					t.cmp_othertype1 in (@cmptype1, 'UNK') AND
					t.cmp_othertype2 in (@cmptype2, 'UNK') AND
					t.cmd_code in (@cmdcode, 'UNKNOWN') AND
					t.cmd_class in (@cmdclass, 'UNKNOWN') AND
					t.trl_type1 in (@trltype1, 'UNK') AND
					t.trl_type2 in (@trltype2, 'UNK') AND
					t.trl_type3 in (@trltype3, 'UNK') AND
					t.trl_type4 in (@trltype4, 'UNK') AND
					t.trk_revtype1 in (@revtype1, 'UNK') AND
					t.trk_revtype2 in (@revtype2, 'UNK') AND
					t.trk_revtype3 in (@revtype3, 'UNK') AND
					t.trk_revtype4 in (@revtype4, 'UNK') AND
					t.trk_originpoint in (@originpoint, 'UNKNOWN') AND
					t.trk_origincity in (@origincity, 0 ) AND
					t.trk_originzip in (@originzip, 'UNKNOWN') AND
					t.trk_origincounty in (@origincounty, 'UNK') AND
					t.trk_originstate in (@originstate, 'XX') AND
					t.trk_destpoint in (@destpoint, 'UNKNOWN') AND
					t.trk_destcity in (@destcity, 0) AND
					t.trk_destzip in (@destzip, 'UNKNOWN') AND
					t.trk_destcounty in (@destcounty, 'UNK') AND
					t.trk_deststate in (@deststate, 'XX') AND
					t.trk_primary = 'N' AND
					t.trk_company in (@company, 'UNK') AND
					t.trk_carrier in (@carrier, 'UNKNOWN') AND
					t.trk_lghtype1 in (@triptype, 'UNK') AND
					t.trk_load in (@loadstat, @matchloadstat) AND
					t.trk_team in (@team, 'UNK') AND
					t.trk_boardcarrier in (@cartype, 'UNK') AND
					t.tar_number in (select b.tar_number
							from 	tariffkey b
							where 	trk_number in
								(select a.trk_number
								 from 	tariffaccessorialstl a
								 where	a.tar_number = @tarnum)) AND
					IsNull(t.mpp_type1,'UNK') in (@drvtype1, 'UNK') AND
					IsNull(t.mpp_type2,'UNK') in (@drvtype2, 'UNK') AND
					IsNull(t.mpp_type3,'UNK') in (@drvtype3, 'UNK') AND
					IsNull(t.mpp_type4,'UNK') in (@drvtype4, 'UNK') AND
					IsNull(t.trc_type1,'UNK') in (@trctype1, 'UNK') AND
					IsNull(t.trc_type2,'UNK') in (@trctype2, 'UNK') AND
					IsNull(t.trc_type3,'UNK') in (@trctype3, 'UNK') AND
					IsNull(t.trc_type4,'UNK') in (@trctype4, 'UNK') AND
					IsNull(t.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
					ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
					ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
					ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
					ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
					ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
					ISNULL(t.trk_ooastop , 0) in (@tooastop, 0)
	END
	ELSE -- Get primary key (ELSE @tar_rate = 0)
	BEGIN
		-- DEBUG: PRINT 'Getting primary rate'
		IF @retrieveby = 'B'
		BEGIN
			insert into @temp
				select t.trk_number,
						t.tar_number,
						t.trk_billto,
						t.trk_orderedby,
						t.cmp_othertype1,
						t.cmp_othertype2,
						t.cmd_code,
						t.cmd_class,
						t.trl_type1,
						t.trl_type2,
						t.trl_type3,
						t.trl_type4,
						t.trk_revtype1,
						t.trk_revtype2,
						t.trk_revtype3,
						t.trk_revtype4,
						t.trk_originpoint,
						t.trk_origincity,
						t.trk_originzip,
						t.trk_origincounty,
						t.trk_originstate,
						t.trk_destpoint,
						t.trk_destcity,
						t.trk_destzip,
						t.trk_destcounty,
						t.trk_deststate,
						t.trk_duplicateseq,
						t.trk_company,
						t.trk_carrier,
						t.trk_lghtype1,
						t.trk_load,
						t.trk_team,
						t.trk_boardcarrier,
						t.trk_minmiles,
						t.trk_maxmiles,
						t.trk_distunit,
						t.trk_minweight,
						t.trk_maxweight,
						t.trk_wgtunit,
						t.trk_minpieces,
						t.trk_maxpieces,
						t.trk_countunit,
						t.trk_minvolume,
						t.trk_maxvolume,
						t.trk_volunit,
						t.trk_minodmiles,
						t.trk_maxodmiles,
						t.trk_odunit,
						t.mpp_type1,
						t.mpp_type2,
						t.mpp_type3,
						t.mpp_type4,
						t.trc_type1,
						t.trc_type2,
						t.trc_type3,
						t.trc_type4,
						t.cht_itemcode,
						t.trk_stoptype,
						t.trk_delays,
						t.trk_carryins1,
						t.trk_carryins2,
						t.trk_ooamileage,
						t.trk_ooastop,
						t.trk_minmaxmiletype,
						t.trk_terms,
						t.trk_triptype_or_region,
						t.trk_tt_or_oregion,
						t.trk_dregion,
						t.cmp_mastercompany,
						0,
						trk_mileagetable,
						trk_fueltableid,
						t.trk_minrevpermile,
						t.trk_maxrevpermile,
						h.cht_currunit	-- blm	11.12.03
				FROM tariffkey t,tariffheader h
				WHERE t.tar_number = h.tar_number AND
						t.trk_startdate <= @billdate AND
						t.trk_enddate >= @billdate AND
						t.trk_minstops <= @stops AND
						t.trk_maxstops >= @stops AND
						t.trk_minlength <= @length AND
						t.trk_maxlength >= @length AND
						t.trk_minwidth <= @width AND
						t.trk_maxwidth >= @width AND
						t.trk_minheight <= @height AND
						t.trk_maxheight >= @height AND
						t.trk_billto in (@billto, 'UNKNOWN') AND
						t.trk_orderedby in (@ordby, 'UNKNOWN') AND
						t.cmp_othertype1 in (@cmptype1, 'UNK') AND
						t.cmp_othertype2 in (@cmptype2, 'UNK') AND
						t.cmd_code in (@cmdcode, 'UNKNOWN') AND
						t.cmd_class in (@cmdclass, 'UNKNOWN') AND
						t.trl_type1 in (@trltype1, 'UNK') AND
						t.trl_type2 in (@trltype2, 'UNK') AND
						t.trl_type3 in (@trltype3, 'UNK') AND
						t.trl_type4 in (@trltype4, 'UNK') AND
						t.trk_revtype1 in (@revtype1, 'UNK') AND
						t.trk_revtype2 in (@revtype2, 'UNK') AND
						t.trk_revtype3 in (@revtype3, 'UNK') AND
						t.trk_revtype4 in (@revtype4, 'UNK') AND
						t.trk_originpoint in (@originpoint, 'UNKNOWN') AND
						t.trk_origincity in (@origincity, 0) AND
						t.trk_originzip in (@originzip, 'UNKNOWN') AND
						t.trk_origincounty in (@origincounty, 'UNK') AND
						t.trk_originstate in (@originstate, 'XX') AND
						t.trk_destpoint in (@destpoint, 'UNKNOWN') AND
						t.trk_destcity in (@destcity, 0) AND
						t.trk_destzip in (@destzip, 'UNKNOWN') AND
						t.trk_destcounty in (@destcounty, 'UNK') AND
						t.trk_deststate in (@deststate, 'XX') AND
						t.trk_primary = 'Y' AND
						t.trk_company in (@company, 'UNK') AND
						t.trk_carrier in (@carrier, 'UNKNOWN') AND
						t.trk_lghtype1 in (@triptype, 'UNK') AND
						t.trk_load in (@loadstat, @matchloadstat) AND
						t.trk_team in (@team, 'UNK') AND
						t.trk_boardcarrier in (@cartype, 'UNK') AND
						IsNull(t.mpp_type1,'UNK') in (@drvtype1, 'UNK') AND
						IsNull(t.mpp_type2,'UNK') in (@drvtype2, 'UNK') AND
						IsNull(t.mpp_type3,'UNK') in (@drvtype3, 'UNK') AND
						IsNull(t.mpp_type4,'UNK') in (@drvtype4, 'UNK') AND
						IsNull(t.trc_type1,'UNK') in (@trctype1, 'UNK') AND
						IsNull(t.trc_type2,'UNK') in (@trctype2, 'UNK') AND
						IsNull(t.trc_type3,'UNK') in (@trctype3, 'UNK') AND
						IsNull(t.trc_type4,'UNK') in (@trctype4, 'UNK') AND
						IsNull(t.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
						ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
						ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
						ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
						ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
						ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
						ISNULL(t.trk_ooastop , 0) in (@tooastop, 0) and
						ISNULL(t.trk_terms , 'UNK') in (@terms, 'UNK')  and
						ISNULL(t.cmp_mastercompany, 'UNKNOWN') in (@mastercompany, 'UNKNOWN')
		END
		else if @retrieveby = 'S'
		BEGIN
			-- DEBUG: PRINT '@retrieveby = "S"'
			insert into @temp
				select t.trk_number,
						t.tar_number,
						t.trk_billto,
						t.trk_orderedby,
						t.cmp_othertype1,
						t.cmp_othertype2,
						t.cmd_code,
						t.cmd_class,
						t.trl_type1,
						t.trl_type2,
						t.trl_type3,
						t.trl_type4,
						t.trk_revtype1,
						t.trk_revtype2,
						t.trk_revtype3,
						t.trk_revtype4,
						t.trk_originpoint,
						t.trk_origincity,
						t.trk_originzip,
						t.trk_origincounty,
						t.trk_originstate,
						t.trk_destpoint,
						t.trk_destcity,
						t.trk_destzip,
						t.trk_destcounty,
						t.trk_deststate,
						t.trk_duplicateseq,
						t.trk_company,
						t.trk_carrier,
						t.trk_lghtype1,
						t.trk_load,
						t.trk_team,
						t.trk_boardcarrier,
						t.trk_minmiles,
						t.trk_maxmiles,
						t.trk_distunit,
						t.trk_minweight,
						t.trk_maxweight,
						t.trk_wgtunit,
						t.trk_minpieces,
 						t.trk_maxpieces,
						t.trk_countunit,
						t.trk_minvolume,
						t.trk_maxvolume,
						t.trk_volunit,
						t.trk_minodmiles,
						t.trk_maxodmiles,
						t.trk_odunit,
						t.mpp_type1,
						t.mpp_type2,
						t.mpp_type3,
						t.mpp_type4,
						t.trc_type1,
						t.trc_type2,
						t.trc_type3,
						t.trc_type4,
						t.cht_itemcode,
						t.trk_stoptype,
						t.trk_delays,
						t.trk_carryins1,
						t.trk_carryins2,
						t.trk_ooamileage,
						t.trk_ooastop ,
						t.trk_minmaxmiletype,
						t.trk_terms,
						t.trk_triptype_or_region,
						t.trk_tt_or_oregion,
						t.trk_dregion,
						t.cmp_mastercompany,
						0,
						'0',
						'' ,
						t.trk_minrevpermile,
						t.trk_maxrevpermile,
						h.cht_currunit  -- blm	11.12.03
				FROM tariffkey t,tariffheaderstl h
			   WHERE t.tar_number = h.tar_number AND
						t.trk_startdate <= @billdate AND
						t.trk_enddate >= @billdate AND
						t.trk_minstops <= @stops AND
						t.trk_maxstops >= @stops AND
						t.trk_minlength <= @length AND
						t.trk_maxlength >= @length AND
						t.trk_minwidth <= @width AND
						t.trk_maxwidth >= @width AND
						t.trk_minheight <= @height AND
						t.trk_maxheight >= @height AND
						t.trk_billto in (@billto, 'UNKNOWN') AND
						t.trk_orderedby in (@ordby, 'UNKNOWN') AND
						t.cmp_othertype1 in (@cmptype1, 'UNK') AND
						t.cmp_othertype2 in (@cmptype2, 'UNK') AND
						t.cmd_code in (@cmdcode, 'UNKNOWN') AND
						t.cmd_class in (@cmdclass, 'UNKNOWN') AND
						t.trl_type1 in (@trltype1, 'UNK') AND
						t.trl_type2 in (@trltype2, 'UNK') AND
						t.trl_type3 in (@trltype3, 'UNK') AND
						t.trl_type4 in (@trltype4, 'UNK') AND
						t.trk_revtype1 in (@revtype1, 'UNK') AND
						t.trk_revtype2 in (@revtype2, 'UNK') AND
						t.trk_revtype3 in (@revtype3, 'UNK') AND
						t.trk_revtype4 in (@revtype4, 'UNK') AND
						t.trk_originpoint in (@originpoint, 'UNKNOWN') AND
						t.trk_origincity in (@origincity, 0) AND
						t.trk_originzip in (@originzip, 'UNKNOWN') AND
						t.trk_origincounty in (@origincounty, 'UNK') AND
						t.trk_originstate in (@originstate, 'XX') AND
						t.trk_destpoint in (@destpoint, 'UNKNOWN') AND
						t.trk_destcity in (@destcity, 0) AND
						t.trk_destzip in (@destzip, 'UNKNOWN') AND
						t.trk_destcounty in (@destcounty, 'UNK') AND
						t.trk_deststate in (@deststate, 'XX') AND
						t.trk_primary = 'Y' AND
						t.trk_company in (@company, 'UNK') AND
						t.trk_carrier in (@carrier, 'UNKNOWN') AND
						t.trk_lghtype1 in (@triptype, 'UNK') AND
						t.trk_load in (@loadstat, @matchloadstat) AND
						t.trk_team in (@team, 'UNK') AND
						t.trk_boardcarrier in (@cartype, 'UNK') AND
						IsNull(t.mpp_type1,'UNK') in (@drvtype1, 'UNK') AND
						IsNull(t.mpp_type2,'UNK') in (@drvtype2, 'UNK') AND
						IsNull(t.mpp_type3,'UNK') in (@drvtype3, 'UNK') AND
						IsNull(t.mpp_type4,'UNK') in (@drvtype4, 'UNK') AND
						IsNull(t.trc_type1,'UNK') in (@trctype1, 'UNK') AND
						IsNull(t.trc_type2,'UNK') in (@trctype2, 'UNK') AND
						IsNull(t.trc_type3,'UNK') in (@trctype3, 'UNK') AND
						IsNull(t.trc_type4,'UNK') in (@trctype4, 'UNK') AND
						IsNull(t.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
						ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
						ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
						ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
						ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
						ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
						ISNULL(t.trk_ooastop , 0) in (@tooastop, 0)
		END
		else -- @retrieveby <> 'S' and @retrieveby <> 'B'
		BEGIN
			-- DEBUG: PRINT '@retrieveby <> "S" and @retrieveby <> "B"'
			insert into @temp
				select t.trk_number,
						t.tar_number,
						t.trk_billto,
						t.trk_orderedby,
						t.cmp_othertype1,
						t.cmp_othertype2,
						t.cmd_code,
						t.cmd_class,
						t.trl_type1,
						t.trl_type2,
						t.trl_type3,
						t.trl_type4,
						t.trk_revtype1,
						t.trk_revtype2,
						t.trk_revtype3,
						t.trk_revtype4,
						t.trk_originpoint,
						t.trk_origincity,
						t.trk_originzip,
						t.trk_origincounty,
						t.trk_originstate,
						t.trk_destpoint,
						t.trk_destcity,
						t.trk_destzip,
						t.trk_destcounty,
						t.trk_deststate,
						t.trk_duplicateseq,
						t.trk_company,
						t.trk_carrier,
						t.trk_lghtype1,
						t.trk_load,
						t.trk_team,
						t.trk_boardcarrier,
						t.trk_minmiles,
						t.trk_maxmiles,
						t.trk_distunit,
						t.trk_minweight,
						t.trk_maxweight,
						t.trk_wgtunit,
						t.trk_minpieces,
 						t.trk_maxpieces,
						t.trk_countunit,
						t.trk_minvolume,
						t.trk_maxvolume,
						t.trk_volunit,
						t.trk_minodmiles,
						t.trk_maxodmiles,
						t.trk_odunit,
						t.mpp_type1,
						t.mpp_type2,
						t.mpp_type3,
						t.mpp_type4,
						t.trc_type1,
						t.trc_type2,
						t.trc_type3,
						t.trc_type4,
						t.cht_itemcode,
						t.trk_stoptype,
						t.trk_delays,
						t.trk_carryins1,
						t.trk_carryins2,
						t.trk_ooamileage,
						t.trk_ooastop ,
						t.trk_minmaxmiletype,
						t.trk_terms,
						t.trk_triptype_or_region,
						t.trk_tt_or_oregion,
						t.trk_dregion,
						t.cmp_mastercompany,
						0,
						'0',
						'',
						t.trk_minrevpermile,
						t.trk_maxrevpermile,
						(select cht_currunit from tariffheader where tariffheader.tar_number = t.tar_number) cht_currunit -- blm	11.12.03

				FROM tariffkey t
			   WHERE t.trk_startdate <= @billdate AND
					t.trk_enddate >= @billdate AND
					t.trk_minstops <= @stops AND
					t.trk_maxstops >= @stops AND
					t.trk_minlength <= @length AND
					t.trk_maxlength >= @length AND
					t.trk_minwidth <= @width AND
					t.trk_maxwidth >= @width AND
					t.trk_minheight <= @height AND
					t.trk_maxheight >= @height AND
					t.trk_billto in (@billto, 'UNKNOWN') AND
					t.trk_orderedby in (@ordby, 'UNKNOWN') AND
					t.cmp_othertype1 in (@cmptype1, 'UNK') AND
					t.cmp_othertype2 in (@cmptype2, 'UNK') AND
					t.cmd_code in (@cmdcode, 'UNKNOWN') AND
					t.cmd_class in (@cmdclass, 'UNKNOWN') AND
					t.trl_type1 in (@trltype1, 'UNK') AND
					t.trl_type2 in (@trltype2, 'UNK') AND
					t.trl_type3 in (@trltype3, 'UNK') AND
					t.trl_type4 in (@trltype4, 'UNK') AND
					t.trk_revtype1 in (@revtype1, 'UNK') AND
					t.trk_revtype2 in (@revtype2, 'UNK') AND
					t.trk_revtype3 in (@revtype3, 'UNK') AND
					t.trk_revtype4 in (@revtype4, 'UNK') AND
					t.trk_originpoint in (@originpoint, 'UNKNOWN') AND
					t.trk_origincity in (@origincity, 0) AND
					t.trk_originzip in (@originzip, 'UNKNOWN') AND
					t.trk_origincounty in (@origincounty, 'UNK') AND
					t.trk_originstate in (@originstate, 'XX') AND
					t.trk_destpoint in (@destpoint, 'UNKNOWN') AND
					t.trk_destcity in (@destcity, 0) AND
					t.trk_destzip in (@destzip, 'UNKNOWN') AND
					t.trk_destcounty in (@destcounty, 'UNK') AND
					t.trk_deststate in (@deststate, 'XX') AND
					t.trk_primary = 'Y' AND
					t.trk_company in (@company, 'UNK') AND
					t.trk_carrier in (@carrier, 'UNKNOWN') AND
					t.trk_lghtype1 in (@triptype, 'UNK') AND
					t.trk_load in (@loadstat, @matchloadstat) AND
					t.trk_team in (@team, 'UNK') AND
					t.trk_boardcarrier in (@cartype, 'UNK') AND
					IsNull(t.mpp_type1,'UNK') in (@drvtype1, 'UNK') AND
					IsNull(t.mpp_type2,'UNK') in (@drvtype2, 'UNK') AND
					IsNull(t.mpp_type3,'UNK') in (@drvtype3, 'UNK') AND
					IsNull(t.mpp_type4,'UNK') in (@drvtype4, 'UNK') AND
					IsNull(t.trc_type1,'UNK') in (@trctype1, 'UNK') AND
					IsNull(t.trc_type2,'UNK') in (@trctype2, 'UNK') AND
					IsNull(t.trc_type3,'UNK') in (@trctype3, 'UNK') AND
					IsNull(t.trc_type4,'UNK') in (@trctype4, 'UNK') AND
					IsNull(t.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
					ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
					ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
					ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
					ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
					ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
					ISNULL(t.trk_ooastop , 0) in (@tooastop, 0)
		END
	END
END
ELSE		-- @Carrier = ''
BEGIN
	-- Get secondary key/s for billing
	-- DEBUG: PRINT 'CARRIER IS EMPTY'
	IF @tarnum > 0
	BEGIN
		-- DEBUG: print '@tarnum > 0'
		insert into @temp
			select t.trk_number,
					t.tar_number,
					t.trk_billto,
					t.trk_orderedby,
					t.cmp_othertype1,
					t.cmp_othertype2,
					t.cmd_code,
					t.cmd_class,
					t.trl_type1,
					t.trl_type2,
					t.trl_type3,
					t.trl_type4,
					t.trk_revtype1,
					t.trk_revtype2,
					t.trk_revtype3,
					t.trk_revtype4,
					t.trk_originpoint,
					t.trk_origincity,
					t.trk_originzip,
					t.trk_origincounty,
					t.trk_originstate,
					t.trk_destpoint,
					t.trk_destcity,
					t.trk_destzip,
					t.trk_destcounty,
					t.trk_deststate,
					t.trk_duplicateseq,
					t.trk_company,
					t.trk_carrier,
					t.trk_lghtype1,
					t.trk_load,
					t.trk_team,
					t.trk_boardcarrier,
					t.trk_minmiles,
					t.trk_maxmiles,
					t.trk_distunit,
					t.trk_minweight,
					t.trk_maxweight,
					t.trk_wgtunit,
					t.trk_minpieces,
 					t.trk_maxpieces,
					t.trk_countunit,
					t.trk_minvolume,
					t.trk_maxvolume,
					t.trk_volunit,
					t.trk_minodmiles,
					t.trk_maxodmiles,
					t.trk_odunit,
					t.mpp_type1,
					t.mpp_type2,
					t.mpp_type3,
					t.mpp_type4,
					t.trc_type1,
					t.trc_type2,
					t.trc_type3,
					t.trc_type4,
					t.cht_itemcode,
					t.trk_stoptype,
					t.trk_delays,
					t.trk_carryins1,
					t.trk_carryins2,
					t.trk_ooamileage,
					t.trk_ooastop ,
					t.trk_minmaxmiletype,
					t.trk_terms,
					t.trk_triptype_or_region,
					t.trk_tt_or_oregion,
					t.trk_dregion,
					t.cmp_mastercompany,
					(select isNull(a.taa_seq,0)
					 from 	tariffaccessorial a
					 where	a.tar_number = @tarnum AND
						a.trk_number = t.trk_number),
					trk_mileagetable,
					trk_fueltableid,
					t.trk_minrevpermile,
					t.trk_maxrevpermile,
					(select cht_currunit from tariffheader where tariffheader.tar_number = t.tar_number) cht_currunit  -- blm	11.12.03
			from tariffkey t
		   where t.trk_startdate <= @billdate AND
				t.trk_enddate >= @billdate AND
				t.trk_minstops <= @stops AND
				t.trk_maxstops >= @stops AND
				t.trk_minlength <= @length AND
				t.trk_maxlength >= @length AND
				t.trk_minwidth <= @width AND
				t.trk_maxwidth >= @width AND
				t.trk_minheight <= @height AND
				t.trk_maxheight >= @height AND
				t.trk_billto in (@billto, 'UNKNOWN') AND
				t.trk_orderedby in (@ordby, 'UNKNOWN') AND
				t.cmp_othertype1 in (@cmptype1, 'UNK') AND
				t.cmp_othertype2 in (@cmptype2, 'UNK') AND
				t.cmd_code in (@cmdcode, 'UNKNOWN') AND
				t.cmd_class in (@cmdclass, 'UNKNOWN') AND
				t.trl_type1 in (@trltype1, 'UNK') AND
				t.trl_type2 in (@trltype2, 'UNK') AND
				t.trl_type3 in (@trltype3, 'UNK') AND
				t.trl_type4 in (@trltype4, 'UNK') AND
				t.trk_revtype1 in (@revtype1, 'UNK') AND
				t.trk_revtype2 in (@revtype2, 'UNK') AND
				t.trk_revtype3 in (@revtype3, 'UNK') AND
				t.trk_revtype4 in (@revtype4, 'UNK') AND
				t.trk_originpoint in (@originpoint, 'UNKNOWN') AND
				t.trk_origincity in (@origincity, 0 ) AND
				t.trk_originzip in (@originzip, 'UNKNOWN') AND
				t.trk_origincounty in (@origincounty, 'UNK') AND
				t.trk_originstate in (@originstate, 'XX') AND
				t.trk_destpoint in (@destpoint, 'UNKNOWN') AND
				t.trk_destcity in (@destcity, 0) AND
				t.trk_destzip in (@destzip, 'UNKNOWN') AND
				t.trk_destcounty in (@destcounty, 'UNK') AND
				t.trk_deststate in (@deststate, 'XX') AND
				t.trk_primary <> 'Y' AND
				t.trk_company in (@company, 'UNK') AND
				t.trk_lghtype1 in (@triptype, 'UNK') AND
				t.trk_load in (@loadstat, @matchloadstat) AND
				t.trk_team in (@team, 'UNK') AND
				t.trk_boardcarrier in (@cartype, 'UNK') AND
				t.tar_number in (select b.tar_number
						from 	tariffkey b
						where 	trk_number in
							(select a.trk_number
							 from 	tariffaccessorial a
							 where	a.tar_number = @tarnum)) AND
				IsNull(t.mpp_type1,'UNK') in (@drvtype1, 'UNK') AND
				IsNull(t.mpp_type2,'UNK') in (@drvtype2, 'UNK') AND
				IsNull(t.mpp_type3,'UNK') in (@drvtype3, 'UNK') AND
				IsNull(t.mpp_type4,'UNK') in (@drvtype4, 'UNK') AND
				IsNull(t.trc_type1,'UNK') in (@trctype1, 'UNK') AND
				IsNull(t.trc_type2,'UNK') in (@trctype2, 'UNK') AND
				IsNull(t.trc_type3,'UNK') in (@trctype3, 'UNK') AND
				IsNull(t.trc_type4,'UNK') in (@trctype4, 'UNK') AND
				IsNull(t.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
				ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
				ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
				ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
				ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
				ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
				ISNULL(t.trk_ooastop , 0) in (@tooastop, 0) and
				ISNULL(t.trk_terms , 'UNK') in (@terms, 'UNK') and
				ISNULL(t.cmp_mastercompany, 'UNKNOWN') in (@mastercompany, 'UNKNOWN')
				AND t.trk_number = (Select min(trk_number) FROM tariffkey c
					WHERE c.tar_number = t.tar_number)
	END
	ELSE IF @tarnum < 0
	BEGIN
		-- DEBUG: print '@tarnum < 0'
		SELECT @tarnum = -@tarnum

		insert into @temp
			select t.trk_number,
					t.tar_number,
					t.trk_billto,
					t.trk_orderedby,
					t.cmp_othertype1,
					t.cmp_othertype2,
					t.cmd_code,
					t.cmd_class,
					t.trl_type1,
					t.trl_type2,
					t.trl_type3,
					t.trl_type4,
					t.trk_revtype1,
					t.trk_revtype2,
					t.trk_revtype3,
					t.trk_revtype4,
					t.trk_originpoint,
					t.trk_origincity,
					t.trk_originzip,
					t.trk_origincounty,
					t.trk_originstate,
					t.trk_destpoint,
					t.trk_destcity,
					t.trk_destzip,
					t.trk_destcounty,
					t.trk_deststate,
					t.trk_duplicateseq,
					t.trk_company,
					t.trk_carrier,
					t.trk_lghtype1,
					t.trk_load,
					t.trk_team,
					t.trk_boardcarrier,
					t.trk_minmiles,
					t.trk_maxmiles,
					t.trk_distunit,
					t.trk_minweight,
					t.trk_maxweight,
					t.trk_wgtunit,
					t.trk_minpieces,
 					t.trk_maxpieces,
					t.trk_countunit,
					t.trk_minvolume,
					t.trk_maxvolume,
					t.trk_volunit,
					t.trk_minodmiles,
					t.trk_maxodmiles,
					t.trk_odunit,
					t.mpp_type1,
					t.mpp_type2,
					t.mpp_type3,
					t.mpp_type4,
					t.trc_type1,
					t.trc_type2,
					t.trc_type3,
					t.trc_type4,
					t.cht_itemcode,
					t.trk_stoptype,
					t.trk_delays,
					t.trk_carryins1,
					t.trk_carryins2,
					t.trk_ooamileage,
					t.trk_ooastop ,
					t.trk_minmaxmiletype,
					t.trk_terms,
					t.trk_triptype_or_region,
					t.trk_tt_or_oregion,
					t.trk_dregion,
					t.cmp_mastercompany,
					0,
					'0',
					'',
					t.trk_minrevpermile,
					t.trk_maxrevpermile,
					(select cht_currunit from tariffheader where tariffheader.tar_number = t.tar_number) cht_currunit -- blm	11.12.03
			FROM tariffkey t
		   WHERE t.trk_startdate <= @billdate AND
					t.trk_enddate >= @billdate AND
					t.trk_minstops <= @stops AND
					t.trk_maxstops >= @stops AND
					t.trk_minlength <= @length AND
					t.trk_maxlength >= @length AND
					t.trk_minwidth <= @width AND
					t.trk_maxwidth >= @width AND
					t.trk_minheight <= @height AND
					t.trk_maxheight >= @height AND
					t.trk_billto in (@billto, 'UNKNOWN') AND
					t.trk_orderedby in (@ordby, 'UNKNOWN') AND
					t.cmp_othertype1 in (@cmptype1, 'UNK') AND
					t.cmp_othertype2 in (@cmptype2, 'UNK') AND
					t.cmd_code in (@cmdcode, 'UNKNOWN') AND
					t.cmd_class in (@cmdclass, 'UNKNOWN') AND
					t.trl_type1 in (@trltype1, 'UNK') AND
					t.trl_type2 in (@trltype2, 'UNK') AND
					t.trl_type3 in (@trltype3, 'UNK') AND
					t.trl_type4 in (@trltype4, 'UNK') AND
					t.trk_revtype1 in (@revtype1, 'UNK') AND
					t.trk_revtype2 in (@revtype2, 'UNK') AND
					t.trk_revtype3 in (@revtype3, 'UNK') AND
					t.trk_revtype4 in (@revtype4, 'UNK') AND
					t.trk_originpoint in (@originpoint, 'UNKNOWN') AND
					t.trk_origincity in (@origincity, 0 ) AND
					t.trk_originzip in (@originzip, 'UNKNOWN') AND
					t.trk_origincounty in (@origincounty, 'UNK') AND
					t.trk_originstate in (@originstate, 'XX') AND
					t.trk_destpoint in (@destpoint, 'UNKNOWN') AND
					t.trk_destcity in (@destcity, 0) AND
					t.trk_destzip in (@destzip, 'UNKNOWN') AND
					t.trk_destcounty in (@destcounty, 'UNK') AND
					t.trk_deststate in (@deststate, 'XX') AND
					t.trk_primary = 'N' AND
					t.trk_company in (@company, 'UNK') AND
					--t.trk_carrier in (@carrier, 'UNKNOWN') AND
					t.trk_lghtype1 in (@triptype, 'UNK') AND
					t.trk_load in (@loadstat, @matchloadstat) AND
					t.trk_team in (@team, 'UNK') AND
					t.trk_boardcarrier in (@cartype, 'UNK') AND
					t.tar_number in (select b.tar_number
							from 	tariffkey b
							where 	trk_number in
								(select a.trk_number
								 from 	tariffaccessorialstl a
								 where	a.tar_number = @tarnum)) AND
					IsNull(t.mpp_type1,'UNK') in (@drvtype1, 'UNK') AND
					IsNull(t.mpp_type2,'UNK') in (@drvtype2, 'UNK') AND
					IsNull(t.mpp_type3,'UNK') in (@drvtype3, 'UNK') AND
					IsNull(t.mpp_type4,'UNK') in (@drvtype4, 'UNK') AND
					IsNull(t.trc_type1,'UNK') in (@trctype1, 'UNK') AND
					IsNull(t.trc_type2,'UNK') in (@trctype2, 'UNK') AND
					IsNull(t.trc_type3,'UNK') in (@trctype3, 'UNK') AND
					IsNull(t.trc_type4,'UNK') in (@trctype4, 'UNK') AND
					IsNull(t.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
					ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
					ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
					ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
					ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
					ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
					ISNULL(t.trk_ooastop , 0) in (@tooastop, 0)
	END
	else
	BEGIN
		-- DEBUG: print '@tarnum = 0'
		-- Get primary key
		if @retrieveby = 'B'
		BEGIN
			-- DEBUG: prrint '@retrieveby = "B"'
			insert into @temp
			select t.trk_number,
					t.tar_number,
					t.trk_billto,
					t.trk_orderedby,
					t.cmp_othertype1,
					t.cmp_othertype2,
					t.cmd_code,
					t.cmd_class,
					t.trl_type1,
					t.trl_type2,
					t.trl_type3,
					t.trl_type4,
					t.trk_revtype1,
					t.trk_revtype2,
					t.trk_revtype3,
					t.trk_revtype4,
					t.trk_originpoint,
					t.trk_origincity,
					t.trk_originzip,
					t.trk_origincounty,
					t.trk_originstate,
					t.trk_destpoint,
					t.trk_destcity,
					t.trk_destzip,
					t.trk_destcounty,
					t.trk_deststate,
					t.trk_duplicateseq,
					t.trk_company,
					t.trk_carrier,
					t.trk_lghtype1,
					t.trk_load,
					t.trk_team,
					t.trk_boardcarrier,
					t.trk_minmiles,
					t.trk_maxmiles,
					t.trk_distunit,
					t.trk_minweight,
					t.trk_maxweight,
					t.trk_wgtunit,
					t.trk_minpieces,
 					t.trk_maxpieces,
					t.trk_countunit,
					t.trk_minvolume,
					t.trk_maxvolume,
					t.trk_volunit,
					t.trk_minodmiles,
					t.trk_maxodmiles,
					t.trk_odunit,
					t.mpp_type1,
					t.mpp_type2,
					t.mpp_type3,
					t.mpp_type4,
					t.trc_type1,
					t.trc_type2,
					t.trc_type3,
					t.trc_type4,
					t.cht_itemcode,
					t.trk_stoptype,
					t.trk_delays,
					t.trk_carryins1,
					t.trk_carryins2,
					t.trk_ooamileage,
					t.trk_ooastop,
					t.trk_minmaxmiletype,
					t.trk_terms,
					t.trk_triptype_or_region,
					t.trk_tt_or_oregion,
					t.trk_dregion,
					t.cmp_mastercompany,
					0,
					trk_mileagetable,
					trk_fueltableid,
					t.trk_minrevpermile,
					t.trk_maxrevpermile,
					h.cht_currunit		-- blm	11.12.03
			FROM tariffkey t,tariffheader h
		   WHERE t.tar_number = h.tar_number AND
				t.trk_startdate <= @billdate AND
				t.trk_enddate >= @billdate AND
				t.trk_minstops <= @stops AND
				t.trk_maxstops >= @stops AND
				t.trk_minlength <= @length AND
				t.trk_maxlength >= @length AND
				t.trk_minwidth <= @width AND
				t.trk_maxwidth >= @width AND
				t.trk_minheight <= @height AND
				t.trk_maxheight >= @height AND
				t.trk_billto in (@billto, 'UNKNOWN') AND
				t.trk_orderedby in (@ordby, 'UNKNOWN') AND
				t.cmp_othertype1 in (@cmptype1, 'UNK') AND
				t.cmp_othertype2 in (@cmptype2, 'UNK') AND
				t.cmd_code in (@cmdcode, 'UNKNOWN') AND
				t.cmd_class in (@cmdclass, 'UNKNOWN') AND
				t.trl_type1 in (@trltype1, 'UNK') AND
				t.trl_type2 in (@trltype2, 'UNK') AND
				t.trl_type3 in (@trltype3, 'UNK') AND
				t.trl_type4 in (@trltype4, 'UNK') AND
				t.trk_revtype1 in (@revtype1, 'UNK') AND
				t.trk_revtype2 in (@revtype2, 'UNK') AND
				t.trk_revtype3 in (@revtype3, 'UNK') AND
				t.trk_revtype4 in (@revtype4, 'UNK') AND
				t.trk_originpoint in (@originpoint, 'UNKNOWN') AND
				t.trk_origincity in (@origincity, 0) AND
				t.trk_originzip in (@originzip, 'UNKNOWN') AND
				t.trk_origincounty in (@origincounty, 'UNK') AND
				t.trk_originstate in (@originstate, 'XX') AND
				t.trk_destpoint in (@destpoint, 'UNKNOWN') AND
				t.trk_destcity in (@destcity, 0) AND
				t.trk_destzip in (@destzip, 'UNKNOWN') AND
				t.trk_destcounty in (@destcounty, 'UNK') AND
				t.trk_deststate in (@deststate, 'XX') AND
				t.trk_primary = 'Y' AND
				t.trk_company in (@company, 'UNK') AND
				--t.trk_carrier in (@carrier, 'UNKNOWN') AND
				t.trk_lghtype1 in (@triptype, 'UNK') AND
				t.trk_load in (@loadstat, @matchloadstat) AND
				t.trk_team in (@team, 'UNK') AND
				t.trk_boardcarrier in (@cartype, 'UNK') AND
				IsNull(t.mpp_type1,'UNK') in (@drvtype1, 'UNK') AND
				IsNull(t.mpp_type2,'UNK') in (@drvtype2, 'UNK') AND
				IsNull(t.mpp_type3,'UNK') in (@drvtype3, 'UNK') AND
				IsNull(t.mpp_type4,'UNK') in (@drvtype4, 'UNK') AND
				IsNull(t.trc_type1,'UNK') in (@trctype1, 'UNK') AND
				IsNull(t.trc_type2,'UNK') in (@trctype2, 'UNK') AND
				IsNull(t.trc_type3,'UNK') in (@trctype3, 'UNK') AND
				IsNull(t.trc_type4,'UNK') in (@trctype4, 'UNK') AND
				IsNull(t.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
				ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
				ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
				ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
				ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
				ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
				ISNULL(t.trk_ooastop , 0) in (@tooastop, 0) and
				ISNULL(t.trk_terms , 'UNK') in (@terms, 'UNK')  and
				ISNULL(t.cmp_mastercompany, 'UNKNOWN') in (@mastercompany, 'UNKNOWN')
		END
    	else if @retrieveby = 'S'
		BEGIN
			-- DEBUG: print '@retrieveby = "S"'
			insert into @temp
				select t.trk_number,
				t.tar_number,
				t.trk_billto,
				t.trk_orderedby,
				t.cmp_othertype1,
				t.cmp_othertype2,
				t.cmd_code,
				t.cmd_class,
				t.trl_type1,
				t.trl_type2,
				t.trl_type3,
				t.trl_type4,
				t.trk_revtype1,
				t.trk_revtype2,
				t.trk_revtype3,
				t.trk_revtype4,
				t.trk_originpoint,
				t.trk_origincity,
				t.trk_originzip,
				t.trk_origincounty,
				t.trk_originstate,
				t.trk_destpoint,
				t.trk_destcity,
				t.trk_destzip,
				t.trk_destcounty,
				t.trk_deststate,
				t.trk_duplicateseq,
				t.trk_company,
				t.trk_carrier,
				t.trk_lghtype1,
				t.trk_load,
				t.trk_team,
				t.trk_boardcarrier,
				t.trk_minmiles,
				t.trk_maxmiles,
				t.trk_distunit,
				t.trk_minweight,
				t.trk_maxweight,
				t.trk_wgtunit,
				t.trk_minpieces,
	 			t.trk_maxpieces,
				t.trk_countunit,
				t.trk_minvolume,
				t.trk_maxvolume,
				t.trk_volunit,
				t.trk_minodmiles,
				t.trk_maxodmiles,
				t.trk_odunit,
				t.mpp_type1,
				t.mpp_type2,
				t.mpp_type3,
				t.mpp_type4,
				t.trc_type1,
				t.trc_type2,
				t.trc_type3,
				t.trc_type4,
				t.cht_itemcode,
				t.trk_stoptype,
				t.trk_delays,
				t.trk_carryins1,
				t.trk_carryins2,
				t.trk_ooamileage,
				t.trk_ooastop ,
				t.trk_minmaxmiletype,
				t.trk_terms,
				t.trk_triptype_or_region,
				t.trk_tt_or_oregion,
				t.trk_dregion,
				t.cmp_mastercompany,
				0,
				'0',
				'' ,
				t.trk_minrevpermile,
				t.trk_maxrevpermile,
				h.cht_currunit		-- blm	11.12.03

			FROM tariffkey t,tariffheaderstl h
		   WHERE t.tar_number = h.tar_number AND
			t.trk_startdate <= @billdate AND
			t.trk_enddate >= @billdate AND
			t.trk_minstops <= @stops AND
			t.trk_maxstops >= @stops AND
			t.trk_minlength <= @length AND
			t.trk_maxlength >= @length AND
			t.trk_minwidth <= @width AND
			t.trk_maxwidth >= @width AND
			t.trk_minheight <= @height AND
			t.trk_maxheight >= @height AND
			t.trk_billto in (@billto, 'UNKNOWN') AND
			t.trk_orderedby in (@ordby, 'UNKNOWN') AND
			t.cmp_othertype1 in (@cmptype1, 'UNK') AND
			t.cmp_othertype2 in (@cmptype2, 'UNK') AND
			t.cmd_code in (@cmdcode, 'UNKNOWN') AND
			t.cmd_class in (@cmdclass, 'UNKNOWN') AND
			t.trl_type1 in (@trltype1, 'UNK') AND
			t.trl_type2 in (@trltype2, 'UNK') AND
			t.trl_type3 in (@trltype3, 'UNK') AND
			t.trl_type4 in (@trltype4, 'UNK') AND
			t.trk_revtype1 in (@revtype1, 'UNK') AND
			t.trk_revtype2 in (@revtype2, 'UNK') AND
			t.trk_revtype3 in (@revtype3, 'UNK') AND
			t.trk_revtype4 in (@revtype4, 'UNK') AND
			t.trk_originpoint in (@originpoint, 'UNKNOWN') AND
			t.trk_origincity in (@origincity, 0) AND
			t.trk_originzip in (@originzip, 'UNKNOWN') AND
			t.trk_origincounty in (@origincounty, 'UNK') AND
			t.trk_originstate in (@originstate, 'XX') AND
			t.trk_destpoint in (@destpoint, 'UNKNOWN') AND
			t.trk_destcity in (@destcity, 0) AND
			t.trk_destzip in (@destzip, 'UNKNOWN') AND
			t.trk_destcounty in (@destcounty, 'UNK') AND
			t.trk_deststate in (@deststate, 'XX') AND
			t.trk_primary = 'Y' AND
			t.trk_company in (@company, 'UNK') AND
			--t.trk_carrier in (@carrier, 'UNKNOWN') AND
			t.trk_lghtype1 in (@triptype, 'UNK') AND
			t.trk_load in (@loadstat, @matchloadstat) AND
			t.trk_team in (@team, 'UNK') AND
			t.trk_boardcarrier in (@cartype, 'UNK') AND
			IsNull(t.mpp_type1,'UNK') in (@drvtype1, 'UNK') AND
			IsNull(t.mpp_type2,'UNK') in (@drvtype2, 'UNK') AND
			IsNull(t.mpp_type3,'UNK') in (@drvtype3, 'UNK') AND
			IsNull(t.mpp_type4,'UNK') in (@drvtype4, 'UNK') AND
			IsNull(t.trc_type1,'UNK') in (@trctype1, 'UNK') AND
			IsNull(t.trc_type2,'UNK') in (@trctype2, 'UNK') AND
			IsNull(t.trc_type3,'UNK') in (@trctype3, 'UNK') AND
			IsNull(t.trc_type4,'UNK') in (@trctype4, 'UNK') AND
			IsNull(t.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
			ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
			ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
			ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
			ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
			ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
			ISNULL(t.trk_ooastop , 0) in (@tooastop, 0)
		END
		else
		BEGIN
			-- DEBUG: print '@retrieveby <> "B" or "S"'
			insert into @temp
			select t.trk_number,
				t.tar_number,
				t.trk_billto,
				t.trk_orderedby,
				t.cmp_othertype1,
				t.cmp_othertype2,
				t.cmd_code,
				t.cmd_class,
				t.trl_type1,
				t.trl_type2,
				t.trl_type3,
				t.trl_type4,
				t.trk_revtype1,
				t.trk_revtype2,
				t.trk_revtype3,
				t.trk_revtype4,
				t.trk_originpoint,
				t.trk_origincity,
				t.trk_originzip,
				t.trk_origincounty,
				t.trk_originstate,
				t.trk_destpoint,
				t.trk_destcity,
				t.trk_destzip,
				t.trk_destcounty,
				t.trk_deststate,
				t.trk_duplicateseq,
				t.trk_company,
				t.trk_carrier,
				t.trk_lghtype1,
				t.trk_load,
				t.trk_team,
				t.trk_boardcarrier,
				t.trk_minmiles,
				t.trk_maxmiles,
				t.trk_distunit,
				t.trk_minweight,
				t.trk_maxweight,
				t.trk_wgtunit,
				t.trk_minpieces,
	 			t.trk_maxpieces,
				t.trk_countunit,
				t.trk_minvolume,
				t.trk_maxvolume,
				t.trk_volunit,
				t.trk_minodmiles,
				t.trk_maxodmiles,
				t.trk_odunit,
				t.mpp_type1,
				t.mpp_type2,
				t.mpp_type3,
				t.mpp_type4,
				t.trc_type1,
				t.trc_type2,
				t.trc_type3,
				t.trc_type4,
				t.cht_itemcode,
				t.trk_stoptype,
				t.trk_delays,
				t.trk_carryins1,
				t.trk_carryins2,
				t.trk_ooamileage,
				t.trk_ooastop ,
				t.trk_minmaxmiletype,
				t.trk_terms,
				t.trk_triptype_or_region,
				t.trk_tt_or_oregion,
				t.trk_dregion,
				t.cmp_mastercompany,
				0,
				'0',
				'',
				t.trk_minrevpermile,
				t.trk_maxrevpermile,
				(select cht_currunit from tariffheader where tariffheader.tar_number = t.tar_number) cht_currunit -- blm	11.12.03

			FROM tariffkey t
		   WHERE t.trk_startdate <= @billdate AND
			t.trk_enddate >= @billdate AND
			t.trk_minstops <= @stops AND
			t.trk_maxstops >= @stops AND
			t.trk_minlength <= @length AND
			t.trk_maxlength >= @length AND
			t.trk_minwidth <= @width AND
			t.trk_maxwidth >= @width AND
			t.trk_minheight <= @height AND
			t.trk_maxheight >= @height AND
			t.trk_billto in (@billto, 'UNKNOWN') AND
			t.trk_orderedby in (@ordby, 'UNKNOWN') AND
			t.cmp_othertype1 in (@cmptype1, 'UNK') AND
			t.cmp_othertype2 in (@cmptype2, 'UNK') AND
			t.cmd_code in (@cmdcode, 'UNKNOWN') AND
			t.cmd_class in (@cmdclass, 'UNKNOWN') AND
			t.trl_type1 in (@trltype1, 'UNK') AND
			t.trl_type2 in (@trltype2, 'UNK') AND
			t.trl_type3 in (@trltype3, 'UNK') AND
			t.trl_type4 in (@trltype4, 'UNK') AND
			t.trk_revtype1 in (@revtype1, 'UNK') AND
			t.trk_revtype2 in (@revtype2, 'UNK') AND
			t.trk_revtype3 in (@revtype3, 'UNK') AND
			t.trk_revtype4 in (@revtype4, 'UNK') AND
			t.trk_originpoint in (@originpoint, 'UNKNOWN') AND
			t.trk_origincity in (@origincity, 0) AND
			t.trk_originzip in (@originzip, 'UNKNOWN') AND
			t.trk_origincounty in (@origincounty, 'UNK') AND
			t.trk_originstate in (@originstate, 'XX') AND
			t.trk_destpoint in (@destpoint, 'UNKNOWN') AND
			t.trk_destcity in (@destcity, 0) AND
			t.trk_destzip in (@destzip, 'UNKNOWN') AND
			t.trk_destcounty in (@destcounty, 'UNK') AND
			t.trk_deststate in (@deststate, 'XX') AND
			t.trk_primary = 'Y' AND
			t.trk_company in (@company, 'UNK') AND
			--t.trk_carrier in (@carrier, 'UNKNOWN') AND
			t.trk_lghtype1 in (@triptype, 'UNK') AND
			t.trk_load in (@loadstat, @matchloadstat) AND
			t.trk_team in (@team, 'UNK') AND
			t.trk_boardcarrier in (@cartype, 'UNK') AND
			IsNull(t.mpp_type1,'UNK') in (@drvtype1, 'UNK') AND
			IsNull(t.mpp_type2,'UNK') in (@drvtype2, 'UNK') AND
			IsNull(t.mpp_type3,'UNK') in (@drvtype3, 'UNK') AND
			IsNull(t.mpp_type4,'UNK') in (@drvtype4, 'UNK') AND
			IsNull(t.trc_type1,'UNK') in (@trctype1, 'UNK') AND
			IsNull(t.trc_type2,'UNK') in (@trctype2, 'UNK') AND
			IsNull(t.trc_type3,'UNK') in (@trctype3, 'UNK') AND
			IsNull(t.trc_type4,'UNK') in (@trctype4, 'UNK') AND
			IsNull(t.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
			ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
			ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
			ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
			ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
			ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
			ISNULL(t.trk_ooastop , 0) in (@tooastop, 0)
		END
	END
END

-- JET - 10/8/08 - PTS 42738, made this part of the query to select into @temp1
-- 33184 delete anything from @temp  where not in @temp_filteredcarriers
delete from @temp where trk_carrier not in (select fcr_carrier from @temp_filteredcarriers)

-- JET - 10/8/08 - PTS 42738, clear duplicate entries from the filtered carrier list
delete from @temp_filteredcarriers where fcr_carrier in (select trk_carrier from @temp)


-- JET - 10/8/08 - PTS 42738, removed the where clause because this list of carriers no longer containes the carrier from the @temp table.
-- merge @temp and the filtered carrier list
insert @temp (trk_carrier)
select fcr_carrier from @temp_filteredcarriers -- where fcr_carrier not in (select trk_carrier from @temp)



--PTS 42887
insert into @temp1
      (trk_number,              /* trk_number 			int null,                         */
      tar_number,               /* tar_number 			int null,                         */
      tar_rate,                 /* tar_rate 			decimal(9,4) null,                */
      trk_carrier,              /* trk_carrier 			varchar(8) null,                  */
      Crh_Total,                /* Crh_Total 			int null,                         */
      Crh_OnTime,               /* Crh_OnTime 			int null,                         */
      cht_itemcode,             /* cht_itemcode 		varchar(6) null,                  */
      cht_description,          /* cht_description 		varchar(30) null,                 */
      Crh_percent,              /* Crh_percent			int null,                         */
      Crh_AveFuel,              /* Crh_AveFuel			money null,                       */
      Crh_AveTotal,             /* Crh_AveTotal			money null,                       */
      Crh_AveAcc,               /* Crh_AveAcc			money null,                       */
      car_name,                 /* car_name				varchar(64) null,                 */
      car_address1,             /* car_address1			Varchar(64) null,                 */
      car_address2,             /* car_address2			Varchar(64) null,                 */
      car_scac,                 /* car_scac				Varchar(64) null,                 */
      car_phone1,               /* car_phone1			varchar(10) null,                 */
      car_phone2,               /* car_phone2			varchar(10) null,                 */
      car_contact,              /* car_contact			varchar(25) null,                 */
      car_phone3,               /* car_phone3			varchar(10) null,                 */
      car_email,                /* car_email			varchar(128) null,                */
      car_currency,             /* car_currency			varchar(6) null,  MRH 11/13/03    */
      cht_currunit,             /* cht_currunit			varchar(6) null,  blm	11.12.03  */
      car_rating,               /* car_rating			varchar(12) NULL,                 */
      cartype1_t,               /* cartype1_t		    varchar(20) NULL,                 */
      cartype2_t,               /* cartype2_t		    varchar(20) NULL,                 */
      cartype3_t,               /* cartype3_t		    varchar(20) NULL,                 */
      cartype4_t,               /* cartype4_t		    varchar(20) NULL,                 */
      car_type1,                /* car_type1			varchar(6)  NULL,                 */
      car_type2,                /* car_type2			varchar(6)  NULL,                 */
      car_type3,                /* car_type3			varchar(6)  NULL,                 */
      car_type4)                /* car_type4			varchar(6)  NULL,                 */

-- JET - 10/8/08 - PTS 42738, changed the joins and the location from where the data is being pulled.
     select t.trk_number,                                           /* int null,                         */
            t.tar_number,                                           /* int null,                         */
            tariffheaderstl.tar_rate,                                   /* decimal(9,4) null,                */
            t.trk_carrier,                                          /* varchar(8) null,                  */
            -- add isnulls to these carhistory values...BDH
            isnull(carrierhistory.crh_Total, 0),                        /* int null,                         */
            isnull(carrierhistory.crh_OnTime, 0),                       /* int null,                         */
            isnull(tariffheaderstl.cht_itemcode, ''),                   /* varchar(6) null,                  */
            isnull(paytype.pyt_description, ''),                        /* varchar(30) null,                 */
            isnull(carrierhistory.Crh_percent, 0),                      /* int null,                         */
            isnull(carrierhistory.Crh_AveFuel, 0),                      /* money null,                       */
            isnull(carrierhistory.Crh_AveTotal, 0),                     /* money null,                       */
            isnull(carrierhistory.Crh_AveAcc, 0),                       /* money null,                       */
            -- Carrier information
            isnull(carrier.car_name, ''),                               /* varchar(64) null,                 */
            isnull(carrier.car_address1, ''),                           /* Varchar(64) null,                 */
            isnull(carrier.car_address2, ''),                           /* Varchar(64) null,                 */
            isnull(carrier.car_scac, ''),                               /* Varchar(64) null,                 */
            isnull(carrier.car_Phone1, ''),                             /* varchar(10) null,                 */
            isnull(carrier.car_Phone2, ''),                             /* varchar(10) null,                 */
            isnull(carrier.car_contact, ''),                            /* varchar(25) null,                 */
            isnull(carrier.car_phone3, ''),                             /* varchar(10) null,                 */
            isnull(carrier.car_email, ''),                              /* varchar(128) null,                */
            isnull(carrier.car_currency, ''),                           /* varchar(6) null,  MRH 11/13/03    */
            t.cht_currunit,           -- blm      11.12.03          /* varchar(6) null,  blm	11.12.03  */
            (SELECT LEFT (name, 12) FROM labelfile WHERE labeldefinition = 'CarrierServiceRating' and abbr = carrier.car_rating), /* varchar(12) NULL,                 */
            (select max(cartype1) from labelfile_headers),              /* varchar(20) NULL,                 */
            (select max(cartype2) from labelfile_headers),              /* varchar(20) NULL,                 */
            (select max(cartype3) from labelfile_headers),              /* varchar(20) NULL,                 */
            (select max(cartype4) from labelfile_headers),              /* varchar(20) NULL,                 */
            carrier.car_type1,                                          /* varchar(6)  NULL,                 */
            carrier.car_type2,                                          /* varchar(6)  NULL,                 */
            carrier.car_type3,                                          /* varchar(6)  NULL,                 */
            carrier.car_type4                                           /* varchar(6)  NULL,                 */
      from @temp t join carrier on (t.trk_carrier = carrier.car_id and t.trk_carrier <> 'UNKNOWN')
                 left outer join carrierhistory on (t.trk_carrier = carrierhistory.crh_carrier)
                 left outer join (tariffheaderstl join paytype on (tariffheaderstl.cht_itemcode = paytype.pyt_itemcode )) on (t.tar_number = tariffheaderstl.tar_number)


if (@carrier = '' or @carrier = 'UNKNOWN' or @carrier is null) and @caf_history_only = 'Y'
begin
	-- 1
	if @origincity > 0 and @destcity = 0 and @originstate = '' and @deststate = ''
		insert into @temp3 select Crh_Carrier from carrierhistory where
		Crh_carrier in (
			select Crh_Carrier from carrierhistorydetail where
			carrierhistorydetail.ord_origincity = @origincity
			group by Crh_Carrier)

	-- 2
	if @origincity > 0 and @destcity = 0 and @originstate = '' and @deststate > ''
		insert into @temp3 select Crh_Carrier from carrierhistory where
		Crh_carrier in (
			select Crh_Carrier from carrierhistorydetail where
			carrierhistorydetail.ord_origincity = @origincity and
			carrierhistorydetail.ord_deststate = @deststate
			group by Crh_Carrier)

	-- 3
	if @origincity > 0 and @destcity = 0 and @originstate > '' and @deststate = ''
		insert into @temp3 select Crh_Carrier from carrierhistory where
		Crh_carrier in (
			select Crh_Carrier from carrierhistorydetail where
			carrierhistorydetail.ord_origincity = @origincity and
			carrierhistorydetail.ord_originstate = @originstate
			group by Crh_Carrier)

	-- 4
	if @origincity > 0 and @destcity = 0 and @originstate > '' and @deststate > ''
		insert into @temp3 select Crh_Carrier from carrierhistory where
		Crh_carrier in (
			select Crh_Carrier from carrierhistorydetail where
			carrierhistorydetail.ord_origincity = @origincity and
			carrierhistorydetail.ord_originstate = @originstate and
			carrierhistorydetail.ord_deststate = @deststate
			group by Crh_Carrier)

	-- 5
	if @origincity > 0 and @destcity > 0 and @originstate = '' and @deststate = ''
		insert into @temp3 select Crh_Carrier from carrierhistory where
		Crh_carrier in (
			select Crh_Carrier from carrierhistorydetail where
			carrierhistorydetail.ord_origincity = @origincity and
			carrierhistorydetail.ord_destcity = @destcity
			group by Crh_Carrier)

	-- 6
	if @origincity > 0 and @destcity > 0 and @originstate = '' and @deststate > ''
		insert into @temp3 select Crh_Carrier from carrierhistory where
		Crh_carrier in (
			select Crh_Carrier from carrierhistorydetail where
			carrierhistorydetail.ord_origincity = @origincity and
			carrierhistorydetail.ord_destcity = @destcity and
			carrierhistorydetail.ord_deststate = @deststate
			group by Crh_Carrier)

	-- 7
	if @origincity > 0 and @destcity > 0 and @originstate > '' and @deststate = ''
		insert into @temp3 select Crh_Carrier from carrierhistory where
		Crh_carrier in (
			select Crh_Carrier from carrierhistorydetail where
			carrierhistorydetail.ord_origincity = @origincity and
			carrierhistorydetail.ord_destcity = @destcity and
			carrierhistorydetail.ord_originstate = @originstate
			group by Crh_Carrier)

	-- 8
	if @origincity > 0 and @destcity > 0 and @originstate > '' and @deststate > ''
		insert into @temp3 select Crh_Carrier from carrierhistory where
		Crh_carrier in (
			select Crh_Carrier from carrierhistorydetail where
			carrierhistorydetail.ord_origincity = @origincity and
			carrierhistorydetail.ord_destcity = @destcity and
			carrierhistorydetail.ord_originstate = @originstate and
			carrierhistorydetail.ord_deststate = @deststate
			group by Crh_Carrier)

	-- 9
	if @origincity = 0 and @destcity > 0 and @originstate = '' and @deststate = ''
		insert into @temp3 select Crh_Carrier from carrierhistory where
		Crh_carrier in (
			select Crh_Carrier from carrierhistorydetail where
			carrierhistorydetail.ord_destcity = @destcity
			group by Crh_Carrier)

	-- 10
	if @origincity = 0 and @destcity > 0 and @originstate = '' and @deststate > ''
		insert into @temp3 select Crh_Carrier from carrierhistory where
		Crh_carrier in (
			select Crh_Carrier from carrierhistorydetail where
			carrierhistorydetail.ord_destcity = @destcity and
			carrierhistorydetail.ord_deststate = @deststate
			group by Crh_Carrier)

	-- 11
	if @origincity = 0 and @destcity > 0 and @originstate > '' and @deststate = ''
		insert into @temp3 select Crh_Carrier from carrierhistory where
		Crh_carrier in (
			select Crh_Carrier from carrierhistorydetail where
			carrierhistorydetail.ord_destcity = @destcity and
			carrierhistorydetail.ord_originstate = @originstate
			group by Crh_Carrier)

	-- 12
	if @origincity = 0 and @destcity > 0 and @originstate > '' and @deststate > ''
		insert into @temp3 select Crh_Carrier from carrierhistory where
		Crh_carrier in (
			select Crh_Carrier from carrierhistorydetail where
			carrierhistorydetail.ord_destcity = @destcity and
			carrierhistorydetail.ord_originstate = @originstate and
			carrierhistorydetail.ord_deststate = @deststate
			group by Crh_Carrier)

	-- 13
	if @origincity = 0 and @destcity = 0 and @originstate = '' and @deststate = ''
		insert into @temp3 select Crh_Carrier from carrierhistory

	-- 14
	if @origincity = 0 and @destcity = 0 and @originstate = '' and @deststate > ''
		insert into @temp3 select Crh_Carrier from carrierhistory where
		Crh_carrier in (
			select Crh_Carrier from carrierhistorydetail where
			carrierhistorydetail.ord_deststate = @deststate
			group by Crh_Carrier)

	-- 15
	if @origincity = 0 and @destcity = 0 and @originstate > '' and @deststate = ''
		insert into @temp3 select Crh_Carrier from carrierhistory where
		Crh_carrier in (
			select Crh_Carrier from carrierhistorydetail where
			carrierhistorydetail.ord_originstate = @originstate
			group by Crh_Carrier)

	-- 16
	if @origincity = 0 and @destcity = 0 and @originstate > '' and @deststate > ''
		insert into @temp3 select Crh_Carrier from carrierhistory where
		Crh_carrier in (
			select Crh_Carrier from carrierhistorydetail where
			carrierhistorydetail.ord_originstate = @originstate and
			carrierhistorydetail.ord_deststate = @deststate
			group by Crh_Carrier)
end

else
begin
	insert into @temp3 (Crh_Carrier) values (@carrier)
end

--PTS 42887
insert into @temp1
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
	cartype1_t,               /* cartype1_t		    varchar(20) NULL,                 */
	cartype2_t,               /* cartype2_t		    varchar(20) NULL,                 */
	cartype3_t,               /* cartype3_t		    varchar(20) NULL,                 */
	cartype4_t,               /* cartype4_t		    varchar(20) NULL,                 */
	car_type1,                /* car_type1			varchar(6)  NULL,                 */
	car_type2,                /* car_type2			varchar(6)  NULL,                 */
	car_type3,                /* car_type3			varchar(6)  NULL,                 */
	car_type4)                /* car_type4			varchar(6)  NULL,                 */
	select
	0,
	0,
	0,
	t.crh_carrier,
	ISNULL(ch.Crh_Total, 0),
	ISNULL(ch.Crh_OnTime, 0),
	'',
	'',
	ISNULL(ch.Crh_Percent, 0),
	ISNULL(ch.Crh_AveFuel, 0),
	ISNULL(ch.Crh_AveTotal, 0),
	ISNULL(ch.Crh_AveAcc, 0),
	c.car_name,
	c.car_address1,
	c.car_address2,
	c.car_scac,
	c.car_Phone1,
	c.car_Phone2,
	c.car_contact,
	c.car_phone3,
	c.car_email,
	c.car_currency,
	'',
	(SELECT name FROM labelfile WHERE labeldefinition = 'CarrierServiceRating' and abbr = (select car_rating from carrier where car_id = t.Crh_carrier)),
    (select max(cartype1) from labelfile_headers),              /* varchar(20) NULL,                 */
	(select max(cartype2) from labelfile_headers),              /* varchar(20) NULL,                 */
	(select max(cartype3) from labelfile_headers),              /* varchar(20) NULL,                 */
	(select max(cartype4) from labelfile_headers),              /* varchar(20) NULL,                 */
	c.car_type1,                                          /* varchar(6)  NULL,                 */
	c.car_type2,                                          /* varchar(6)  NULL,                 */
	c.car_type3,                                          /* varchar(6)  NULL,                 */
	c.car_type4                                           /* varchar(6)  NULL,                 */
	from @temp3 t inner join carrier c on t.crh_carrier = c.car_id and c.car_id <> 'UNKNOWN'
	              left outer join carrierhistory ch on t.crh_carrier = ch.crh_carrier
--PTS 42887

--if NOT history only then let insert happen
-- moved lower
if @caf_history_only = 'Y'
begin
	--orig
	delete from @temp1 where trk_Carrier not in (select crh_carrier from carrierhistory)
end



-- 34777 10/6 BDH
if @caf_history_only = 'Y' and (@origincity > 0 or @destcity > 0 or @originstate  > '' or @deststate > '')
begin
	-- DEBUG: print 'deleting from temp1 where not in temp3'
	delete from @temp1 where trk_Carrier not in (select crh_carrier from @temp3)
end

-- DEBUG: select 'Temp1 prior to rate processing', * from @temp1

-- 33184 start
-- JET - 5/6/08 - PTS42824, compare city as well as state
/* 04/30/2009 MDH PTS 46785: Added code to search O/D companies as well */
if (len(@originstate) > 0 and len(@deststate) > 0) or (@origincity > 0 and @destcity > 0) OR (len (@origin_cmpid)>0 OR len (@dest_cmpid)>0)
begin
	-- DEBUG: print 'Here'
	select @min_tar_number = min(tar_number) from @temp1 where isnull(tar_number, 0) > 0 and isnull(tar_rate, 0) = 0
	while isnull(@min_tar_number, 0) > 0
	begin
		-- DEBUG: print 'in loop, tariff number ' + CAST (@min_tar_number AS char (5))
		-- If after both col/row originstate/deststate searches we find no rates, delete tar_number from @temp1.
		set @ratematch = 0

		select @ratematch = r.tra_rate
			from tariffheaderstl h, tariffrowcolumnstl rc, tariffratestl r
			where h.tar_number = @min_tar_number
			and h.tar_number = rc.tar_number
			and rc.trc_number = r.trc_number_col
			and r.trc_number_row = (select trc_number from tariffrowcolumnstl
						where tar_number = @min_tar_number and trc_rowcolumn = 'R' and ((trc_matchvalue = convert(varchar(9), @origincity) and convert(varchar(9), @origincity) > 0) or trc_matchvalue = @originstate)) --(@origincity = 0 and trc_matchvalue = @originstate)))
			and r.trc_number_col = (select trc_number from tariffrowcolumnstl
						where tar_number = @min_tar_number and trc_rowcolumn = 'C' and ((trc_matchvalue = convert(varchar(9), @destcity) and convert(varchar(9), @destcity) > 0) or trc_matchvalue = @deststate)) --(@destcity = 0 and trc_matchvalue = @deststate)))
		-- DEBUG: print @ratematch
		if ISNULL (@ratematch, 0) = 0
		begin
    		select @ratematch = r.tra_rate
				from tariffheaderstl h, tariffrowcolumnstl rc, tariffratestl r
				where h.tar_number = @min_tar_number
				and h.tar_number = rc.tar_number
				and rc.trc_number = r.trc_number_col
				and r.trc_number_row = (select trc_number from tariffrowcolumnstl
							where tar_number = @min_tar_number and trc_rowcolumn = 'R' and ((trc_matchvalue = convert(varchar(9), @destcity) and convert(varchar(9), @destcity) > 0) or trc_matchvalue = @deststate)) --(@destcity = 0 and trc_matchvalue = @deststate)))
				and r.trc_number_col = (select trc_number from tariffrowcolumnstl
							where tar_number = @min_tar_number and trc_rowcolumn = 'C' and ((trc_matchvalue = convert(varchar(9), @origincity) and convert(varchar(9), @origincity) > 0) or trc_matchvalue = @originstate)) --(@origincity = 0 and trc_matchvalue = @originstate)))
			-- DEBUG: print @ratematch
		end

		/* 04/30/2009 MDH PTS 46785: <<BEGIN>> Check for o/d companies */
		IF ISNULL (@ratematch, 0) = 0
		BEGIN
			-- DEBUG: print 'Here2'
			SELECT @ratematch = r.tra_rate
				FROM tariffheaderstl h JOIN tariffratestl r ON r.tar_number = h.tar_number
					JOIN tariffrowcolumnstl rc ON ( h.tar_number = rc.tar_number AND r.trc_number_col = rc.trc_number)
				WHERE h.tar_number = @min_tar_number
				AND r.trc_number_row = (SELECT trc_number FROM tariffrowcolumnstl
										WHERE tar_number = @min_tar_number
										  AND trc_rowcolumn = 'R'
										  AND trc_matchvalue = @origin_cmpid
										  AND  @origin_cmpid <> 'UNKNOWN')
				AND rc.trc_matchvalue = @dest_cmpid
				AND h.tar_rowbasis = 'OCM'
				AND h.tar_colbasis = 'DCM'
			-- DEBUG: print ISNULL (@ratematch, -1)
		END
		IF ISNULL (@ratematch, 0) = 0
		BEGIN
			-- DEBUG: print 'here3'
			SELECT @ratematch = r.tra_rate
				FROM tariffheaderstl h JOIN tariffratestl r ON r.tar_number = h.tar_number
					JOIN tariffrowcolumnstl rc ON ( h.tar_number = rc.tar_number AND r.trc_number_col = rc.trc_number)
				WHERE h.tar_number = @min_tar_number
				AND r.trc_number_row = (SELECT trc_number FROM tariffrowcolumnstl
										WHERE tar_number = @min_tar_number
										  AND trc_rowcolumn = 'R'
										  AND trc_matchvalue = @dest_cmpid
										  AND  @dest_cmpid <> 'UNKNOWN')
				AND rc.trc_matchvalue = @origin_cmpid
				AND h.tar_rowbasis = 'DCM'
				AND h.tar_colbasis = 'OCM'
			-- DEBUG: print ISNULL (@ratematch, -1)
		END
		/* 04/30/2009 MDH PTS 46785: <<END>> */

		if ISNULL (@ratematch, 0) = 0
		begin
			-- DEBUG: print 'deleting row from @temp1'
			delete from @temp1 where tar_number = @min_tar_number
		end
		else
		begin
			--update @temp1 set tar_rate = Value from above.  Don't do count.. get value.  BDH
			update @temp1
				set tar_rate = @ratematch
				where tar_number = @min_tar_number
		end

		select @min_tar_number = min(tar_number) from @temp1 where tar_number > @min_tar_number and isnull(tar_rate, 0) = 0
	end
end



update @temp1 set exp_priority1 =
(select count(0) from expiration
where exp_idtype = 'CAR'
and exp_id = trk_carrier
and exp_priority = 1
and exp_completed = 'N'
and @stp_departure_dt > exp_expirationdate)

update @temp1 set exp_priority2 =
(select count(0) from expiration
where exp_idtype = 'CAR'
and exp_id = trk_carrier
and exp_priority > 1
and exp_completed = 'N'
and @stp_departure_dt > exp_expirationdate)
-- 33184 end

--drop table @temp3
/* MRH 4/26/2002 Get all carrier information from the legheader for the
same city pairs  can't do this select real time... need the shipper consinee cities from the order header */
--select .. from legheader where (datediff(day, lgh_enddate, dbo.tmw_getdate()) <= 90) and lgh_carrier <> 'UNKNOWN' and


-- Start BDH 5/15/08 PTS 42689.  Eliminate carriers that do not meet load requirements.
select @check_loadreqs = Upper(Left(IsNull(gi_string1, 'N'), 1)) from generalinfo WHERE gi_name = 'IncludeLoadReqsinACS'
-- DEBUG: print 'about to process load requirements'
if @check_loadreqs <> 'N'
begin
	--exec proc that populates the load requirements window:
	insert @temp_loadreqs exec d_notices_lrq_sp_with_car
		'',--@drv1		VARCHAR(8),
		'',--@drv2		VARCHAR(8),
		'',--@trc		VARCHAR(8),
		'',--@trl1		VARCHAR(13),
		'',--@trl2		VARCHAR(13),
		'',--@car		VARCHAR(8),
		@first_stp_departure_dt,
		@stp_departure_dt,
		@reldate,
		'',--@trl1_startdate DATETIME,
		'',--@trl1_enddate	DATETIME,
		'',--@trl2_startdate DATETIME,
		'',--@trl2_enddate	DATETIME,
		@lgh_number, --3172
		@mov_number,  --2961
		'',--@chassis,
		@reldate, --@chassis_startdate,
		@reldate, --@chassis_enddate,
		'',--@chassis2,
		@reldate, --@chassis2_startdate,
		@reldate, --@chassis2_enddate,
		'',--@dolly,
		@reldate, --@dolly_startdate,
		@reldate, --@dolly_enddate,
		'',--@dolly2,
		@reldate, --@dolly2_startdate,
		@reldate, --@dolly2_enddate,
		'',--@trailer3,
		@reldate, --@trailer3_startdate,
		@reldate, --@trailer3_enddate,
		'',--@trailer4,
		@reldate, --@trailer4_startdate,
		@reldate --@trailer4_enddate

	if (select count(*) from @temp_loadreqs where isnull(lrq_equip_type, '') <> '') > 0
	begin
		select @lrq_id = isnull(min(lrq_id), 0) from @temp_loadreqs
		while @lrq_id > 0
		begin

			select @lrq_equip_type = lrq_equip_type,
				@lrq_not = lrq_not,
				@lrq_type = lrq_type,
				@lrq_mandatory = lrq_mandatory,
				@lrq_quantity = lrq_quantity,
				@lrq_expire_date = lrq_expire_date
			from @temp_loadreqs where lrq_id = @lrq_id

			if @check_loadreqs in ('M', 'S')
			begin
				if @lrq_expire_date < @first_stp_departure_dt
				begin
					goto skiploadreq
				end

				if @check_loadreqs = 'M' and @lrq_mandatory = 'N'  -- not mandatory
				begin
					goto skiploadreq
				end
				else
				begin
					if @lrq_not = 'N'  -- Should/Must NOT have
					begin
						if @lrq_equip_type = 'DRV'
						begin
							-- DEBUG: print 'Deleting carrier(s) because of driver load requirement (N)'
							delete from @temp1
							where trk_carrier in (
								select distinct drq_driver from driverqualifications
								where drq_source = 'CAR'
								and drq_type = @lrq_type
								and drq_expire_date >= @first_stp_departure_dt)
						end

						if @lrq_equip_type = 'TRC'
						begin
							-- DEBUG: print 'Deleting carrier(s) because of tractor load requirement (N)'
							delete from @temp1
							where trk_carrier in (
								select distinct tca_tractor from tractoraccesories
								where tca_source = 'CAR'
								and tca_type = @lrq_type
								and tca_expire_date >= @first_stp_departure_dt)
						end

						if @lrq_equip_type = 'TRL'
						begin
							-- DEBUG: print 'Deleting carrier(s) because of trailer load requirement (N)'
							delete from @temp1
							where trk_carrier in (
								select distinct ta_trailer from trlaccessories
								where ta_source = 'CAR'
								and ta_type = @lrq_type
								and ta_expire_date >= @first_stp_departure_dt)
						end

						if @lrq_equip_type = 'CAR'
						begin
							-- DEBUG: print 'Deleting carrier(s) because of carrier load requirement (N)'
							delete from @temp1
							where trk_carrier in (
								select distinct caq_carrier_id from carrierqualifications
								where caq_type = @lrq_type
								and caq_expire_date >= @first_stp_departure_dt)
						end
					end

					if @lrq_not = 'Y'  -- Should/Must have.
					begin
						if @lrq_equip_type = 'DRV'
						begin
							-- DEBUG: print 'Deleting carrier(s) because of driver load requirement (Y)'
							delete from @temp1
							where trk_carrier not in (
								select distinct drq_driver from driverqualifications
								where drq_source = 'CAR'
								and drq_type = @lrq_type
 								and drq_expire_date >= @stp_departure_dt)
						end

						if @lrq_equip_type = 'TRC'
						begin
							-- DEBUG: print 'Deleting carrier(s) because of tractor load requirement (Y)'
							delete from @temp1
							where trk_carrier not in (
								select distinct tca_tractor from tractoraccesories
								where tca_source = 'CAR'
								and tca_type = @lrq_type
								and tca_expire_date >= @stp_departure_dt)
						end

						if @lrq_equip_type = 'TRL'
						begin
							-- DEBUG: print 'Deleting carrier(s) because of trailer load requirement (Y)'
							delete from @temp1
							where trk_carrier not in (
								select distinct ta_trailer from trlaccessories
								where ta_source = 'CAR'
								and ta_type = @lrq_type
								and ta_expire_date >= @stp_departure_dt)
						end

						if @lrq_equip_type = 'CAR'
						begin
							-- DEBUG: print 'Deleting carrier(s) because of carrier load requirement (Y)'
							delete from @temp1
							where trk_carrier not in (
								select distinct caq_carrier_id from carrierqualifications
								where caq_type = @lrq_type
								and caq_expire_date >= @stp_departure_dt)
						end
					end

				end
			end

			skiploadreq:
			select @lrq_id = isnull(min(lrq_id), 0) from @temp_loadreqs where lrq_id  > @lrq_id

		end
	end
end
-- BDH PTS 42689 end

Select 	distinct isnull(trk_number,''),
	isnull(tar_number,0),
	isnull(tar_rate,0),
	isnull(trk_carrier,''),
	isnull(Crh_Total,0),
	isnull(Crh_OnTime,0),
	isnull(cht_itemcode,''),
	isnull(cht_description,''),
	isnull(crh_percent,''),
	isnull(Crh_AveFuel,0),
	isnull(Crh_AveTotal,0),
	isnull(Crh_AveAcc,0),
	isnull(car_name,''),
	isnull(car_address1,''),
	isnull(car_address2,''),
	isnull(car_scac,''),
	isnull(car_phone1,''),
	isnull(car_phone2,''),
	isnull(car_contact,''),
	isnull(car_phone3,''),
	isnull(car_email,''),
	isnull(car_currency, ''),		-- MRH 11/13/03
	isnull(cht_currunit, ''),
	isnull(car_rating, ''),
	isnull(exp_priority1, 0),
	isnull(exp_priority2, 0),
    isnull(cartype1_t,'CarType1'),
    isnull(cartype2_t,'CarType2'),
    isnull(cartype3_t,'CarType3'),
    isnull(cartype4_t,'CarType4'),
	isnull(car_type1,'UNK'),
	isnull(car_type2,'UNK'),
	isnull(car_type3,'UNK'),
	isnull(car_type4,'UNK')
from @temp1 t
where t.trk_carrier in (select car_id from carrier where car_status <> 'OUT')  --JLB PTS 43941


GO
GRANT EXECUTE ON  [dbo].[d_brk_gettariffkeys_sp] TO [public]
GO
