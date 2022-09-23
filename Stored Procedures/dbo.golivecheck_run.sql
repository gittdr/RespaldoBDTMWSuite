SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   PROC [dbo].[golivecheck_run]


AS


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


declare @glc_rundate datetime
set @glc_rundate = GetDate()


/********************************/
/* Update golivecheck_tsuite db */
/********************************/

declare @glc_version varchar(15)
declare @glc_trc_lic_count int
declare @glc_remitto varchar(255)


set @glc_version = (select top 1 dbversion from ps_version_log order by begindate desc)

select @glc_trc_lic_count = count (*)FROM tractorprofile 
			WHERE ( trc_status <> 'OUT' AND trc_status <> 'END' ) 
			AND trc_retiredate > getdate ( ) 
			AND trc_number <> 'UNKNOWN'


select ivs_remittocompanyname,count(*) 'Count' 
into #remit
from invoiceselection
where ivs_remittocompanyname not like 'PLACE REMIT TO%'
group by ivs_remittocompanyname

select @glc_remitto = (select top 1 UPPER(ivs_remittocompanyname)
							from #remit
							where [Count] = (select max([Count])from #remit))

drop table #remit


INSERT INTO golivecheck_tsuite (glc_rundate, glc_version, glc_trc_lic_count, glc_remitto)
VALUES(@glc_rundate, @glc_version, @glc_trc_lic_count, @glc_remitto)




/**********************************/
/* Update golivecheck_sysadmin db */
/**********************************/

declare @glc_cnt_users int
declare @glc_cnt_groups int
declare @glc_pct_usrtogrp float

select @glc_cnt_users = count(*)from ttsusers where usr_userid not like ('%TMW%')
select @glc_cnt_groups = count(*) from ttsgroups
select @glc_pct_usrtogrp = count(*) from ttsusers where exists (select usr_userid from ttsgroupasgn where usr_userid = ttsusers.usr_userid and usr_userid not like ('%TMW%'))

IF @glc_cnt_users > 0
BEGIN
set @glc_pct_usrtogrp = @glc_pct_usrtogrp / @glc_cnt_users
END
ELSE set @glc_pct_usrtogrp = 0

INSERT INTO golivecheck_sysadmin (glc_rundate, glc_cnt_users, glc_cnt_groups, glc_pct_usrtogrp)
VALUES (@glc_rundate, @glc_cnt_users, @glc_cnt_groups, @glc_pct_usrtogrp)




/***********************************/
/* Update golivecheck_filemaint db */
/***********************************/

declare @glc_pct_cty_valid_reg1 float
declare @glc_cnt_company int
declare @glc_cnt_nonimp_company int
declare @glc_cnt_act_drv int
declare @glc_cnt_manual_drv int
declare @glc_cnt_act_trc int
declare @glc_cnt_manual_trc int
declare @glc_cnt_pr_trc int
declare @glc_cnt_ap_no_payto_trc int
declare @glc_cnt_act_trl int
declare @glc_cnt_act_payto int
declare @glc_cnt_orph_payto int
declare @glc_cnt_act_car int
declare @glc_cnt_no_acct_car int
declare @glc_cnt_glreset int
declare @glc_cnt_pyd_gl int
declare @glc_cnt_inv_gl int
declare @glc_cnt_badzip_company int
declare @glc_cnt_act_billto_company int
declare @glc_cnt_company_directions int
declare @glc_cnt_ap_drv int
declare @glc_cnt_ap_drv_no_payto int



declare @cnt_city int
select @cnt_city = count(*) from city
select @glc_pct_cty_valid_reg1 = count(*) from city where cty_region1 in (select distinct rgh_id from regionheader)
IF @cnt_city > 0
BEGIN
set @glc_pct_cty_valid_reg1 = @glc_pct_cty_valid_reg1 / @cnt_city
END
ELSE set @glc_pct_cty_valid_reg1 = 0

select @glc_cnt_company = count(*) from company where cmp_id <> 'UNKNOWN'

select @glc_cnt_nonimp_company = count(*) from company where cmp_updatedby <> 'IMPORT' and cmp_id <> 'UNKNOWN'

select @glc_cnt_act_drv = count(*) from manpowerprofile where mpp_status <> 'OUT' and mpp_id <> 'UNKNOWN'

select @glc_cnt_manual_drv = count(*) from manpowerprofile where mpp_updatedby <> 'IMPORT' and mpp_id <> 'UNKNOWN'

select @glc_cnt_act_trc = count(*) from tractorprofile where trc_status <> 'OUT' and trc_number <> 'UNKNOWN'

select @glc_cnt_manual_trc = count(*) from tractorprofile where trc_updatedby <> 'IMPORT' and trc_number <> 'UNKNOWN'

select @glc_cnt_pr_trc = count(*) from tractorprofile where trc_actg_type = 'P' and trc_number <> 'UNKNOWN' and trc_status <> 'OUT'

select @glc_cnt_ap_no_payto_trc = count(*) from tractorprofile where trc_actg_type = 'A' and trc_owner = 'UNKNOWN' and trc_number <> 'UNKNOWN' and trc_status <> 'OUT'

select @glc_cnt_act_trl = count(*) from trailerprofile where trl_status <> 'OUT' and trl_id <> 'UNKNOWN'

select @glc_cnt_act_payto = count(*) from payto where pto_status = 'ACT' and pto_id <> 'UNKNOWN'

select @glc_cnt_orph_payto = (select distinct count(pto_id) from payto
								where pto_status = 'ACT'
								and pto_id <> 'UNKNOWN'
								and not exists (select mpp_payto from manpowerprofile where mpp_payto = payto.pto_id)
								and not exists (select tpr_payto from thirdpartyprofile where tpr_payto = payto.pto_id)
								and not exists (select trc_owner from tractorprofile where trc_owner = payto.pto_id)
								and not exists (select trl_owner from trailerprofile where trl_owner = payto.pto_id)
								and not exists (select pto_id from carrier where pto_id = payto.pto_id))

select @glc_cnt_act_car = count(*) from carrier where car_status = 'ACT' and car_id <> 'UNKNOWN'

select @glc_cnt_no_acct_car = count(*) from carrier where car_actg_type = 'N' and car_id <> 'UNKNOWN' and car_status = 'ACT'

select @glc_cnt_glreset = count(*) from gl_reset

select @glc_cnt_pyd_gl = count(*) from paydetail where ISNUMERIC(pyd_glnum) = 0

--select @glc_cnt_inv_gl = count(*) from invoicedetail where ISNUMERIC(ivd_glnum) = 0 and cht_itemcode <> 'DEL'
select @glc_cnt_inv_gl = count(*) from invoicedetail where (ivd_glnum is null or ivd_glnum = '') and cht_itemcode <> 'DEL'

select @glc_cnt_badzip_company = count(*) from company where len(cmp_zip) < 5 or cmp_zip is null and cmp_id <> 'UNKNOWN'

select @glc_cnt_act_billto_company = count(*) from company where cmp_active = 'Y' and cmp_billto = 'Y'

select @glc_cnt_company_directions = count(*) from company where isnull(convert(varchar(255),cmp_directions),'') = '' and (cmp_shipper = 'Y' or cmp_consingee = 'Y')

select @glc_cnt_ap_drv = count(*) from manpowerprofile where mpp_actg_type = 'A' and mpp_status <> 'OUT'

select @glc_cnt_ap_drv_no_payto = count(*) from manpowerprofile where mpp_actg_type = 'A' and mpp_payto = 'UNKNOWN' and mpp_status <> 'OUT'


INSERT INTO golivecheck_filemaint 
		(glc_rundate, glc_pct_cty_valid_reg1, glc_cnt_company, glc_cnt_nonimp_company,
		 glc_cnt_act_drv, glc_cnt_manual_drv, glc_cnt_act_trc, glc_cnt_manual_trc,
		 glc_cnt_pr_trc, glc_cnt_ap_no_payto_trc, glc_cnt_act_trl, glc_cnt_act_payto,
		 glc_cnt_orph_payto, glc_cnt_act_car, glc_cnt_no_acct_car, glc_cnt_glreset,
		 glc_cnt_pyd_gl, glc_cnt_inv_gl, glc_cnt_badzip_company, glc_cnt_act_billto_company,
		 glc_cnt_company_directions, glc_cnt_ap_drv, glc_cnt_ap_drv_no_payto)
VALUES (@glc_rundate, @glc_pct_cty_valid_reg1, @glc_cnt_company, @glc_cnt_nonimp_company,
		@glc_cnt_act_drv, @glc_cnt_manual_drv, @glc_cnt_act_trc, @glc_cnt_manual_trc,
		@glc_cnt_pr_trc, @glc_cnt_ap_no_payto_trc, @glc_cnt_act_trl, @glc_cnt_act_payto,
		@glc_cnt_orph_payto, @glc_cnt_act_car, @glc_cnt_no_acct_car, @glc_cnt_glreset,
		@glc_cnt_pyd_gl, @glc_cnt_inv_gl, @glc_cnt_badzip_company, @glc_cnt_act_billto_company,
		@glc_cnt_company_directions, @glc_cnt_ap_drv, @glc_cnt_ap_drv_no_payto)






/************************************/
/* Update golivecheck_orderentry db */
/************************************/

declare @glc_cnt_orders int
declare @glc_cnt_orders_cmp int
declare @glc_cnt_orders_noncmp int
declare @glc_cnt_orders_copy int
declare @glc_cnt_orders_noncopy int
declare @glc_cnt_orders_noncopy_tdy int
declare @glc_cnt_orders_noncopy_nty int
declare @glc_cnt_orders_mst int
declare @glc_cnt_orders_cpy_from_mst int
declare @glc_cnt_users_create_orders int
-- Added v1.2
declare @glc_cnt_orders_imported int


select @glc_cnt_orders = count(*) from orderheader

select @glc_cnt_orders_cmp = count(*) from orderheader where ord_status = 'CMP'

select @glc_cnt_orders_noncmp = count(*) from orderheader where ord_status in ('AVL','PLN','DSP','STD', 'PND', 'MPN', 'PRK')

select @glc_cnt_orders_copy = count(*) from orderheader where ord_fromorder is not null or ord_fromorder <> 'UNKNOWN'

select @glc_cnt_orders_noncopy = count(*) from orderheader where ord_fromorder is null or ord_fromorder = 'UNKNOWN'

select @glc_cnt_orders_noncopy_tdy = count(*) from orderheader where (ord_fromorder is null or ord_fromorder = 'UNKNOWN') and datediff(d,ord_bookdate,GetDate()) <= 30

select @glc_cnt_orders_noncopy_nty = count(*) from orderheader where (ord_fromorder is null or ord_fromorder = 'UNKNOWN') and datediff(d,ord_bookdate,GetDate()) <= 90

select @glc_cnt_orders_mst = count(*) from orderheader where ord_status = 'MST'

select @glc_cnt_orders_cpy_from_mst = count(*) from orderheader o
																				where (ord_fromorder is not null or ord_fromorder <> 'UNKNOWN')
																					and (select ord_status from orderheader o2 where o2.ord_number = o.ord_fromorder) = 'MST'

select @glc_cnt_users_create_orders = (select count(*) from
												(
												select ord_bookedby, count(*) Count from orderheader
												where (ord_fromorder is null or ord_fromorder = 'UNKNOWN')
												and ord_bookedby not like '%TMW%'
												and ord_bookedby <> 'IMPORT'
												and ord_bookedby <> 'sa'
												group by ord_bookedby
												having count(*) > 20
												) as c)

select @glc_cnt_orders_imported = count(*) from orderheader where ord_bookedby = 'IMPORT'





INSERT INTO golivecheck_orderentry 
		(glc_rundate, glc_cnt_orders, glc_cnt_orders_cmp, glc_cnt_orders_copy,
		glc_cnt_orders_noncmp, glc_cnt_orders_noncopy, glc_cnt_orders_noncopy_tdy, glc_cnt_orders_noncopy_nty, 
		glc_cnt_orders_mst, glc_cnt_orders_cpy_from_mst, glc_cnt_users_create_orders, glc_cnt_orders_imported)
VALUES (@glc_rundate, @glc_cnt_orders, @glc_cnt_orders_cmp, @glc_cnt_orders_copy,
		@glc_cnt_orders_noncmp, @glc_cnt_orders_noncopy, @glc_cnt_orders_noncopy_tdy, @glc_cnt_orders_noncopy_nty, 
		@glc_cnt_orders_mst, @glc_cnt_orders_cpy_from_mst, @glc_cnt_users_create_orders, @glc_cnt_orders_imported)




/***********************************/
/* Update golivecheck_vdispatch db */
/***********************************/

declare @glc_cnt_splittrips int
declare @glc_cnt_xdock int
declare @glc_cnt_mtmoves int
declare @glc_pct_moves_with_mtevent float
declare @glc_cnt_trlbeams int
declare @glc_cnt_tripviews int
declare @glc_cnt_resourceviews int
declare @glc_chr_setregions varchar(1)
declare @glc_pct_org_reg1 float
declare @glc_cnt_consolidated int
declare @glc_pct_prerated float
declare @glc_pct_drv_util float
declare @glc_pct_trc_util float
declare @glc_pct_trl_util float
declare @glc_cnt_ord_car_asgn int
declare @glc_pct_bad_mileage float
declare @glc_cnt_lgh_with_payable int
declare @glc_cnt_lgh_no_payable int
declare @glc_cnt_upd_by_tmail int
--Added v1.2
declare @glc_cnt_drvbeams int
declare @glc_cnt_trcbeams int


select @glc_cnt_splittrips = count(distinct mov_number) from legheader where lgh_split_flag = 'S'

select @glc_cnt_xdock = count(distinct mov_number) from stops where stp_event = 'XDL'

select @glc_cnt_mtmoves = count(distinct mov_number) from legheader where ord_hdrnumber = 0

declare @cnt_moves_with_mtevent float
declare @cnt_all_moves float
select @cnt_all_moves = count(distinct mov_number) from stops
select @cnt_moves_with_mtevent = count(distinct mov_number) from stops where stp_event in ('IBMT','BMT','IBBT','BBT','IEMT','EMT','IEBT','EBT')
IF @cnt_all_moves > 0
BEGIN
set @glc_pct_moves_with_mtevent = @cnt_moves_with_mtevent / @cnt_all_moves
END
ELSE set @glc_pct_moves_with_mtevent = 0


/* @glc_cnt_trlbeams START */
SELECT DISTINCT 
   asgn_id,
   lgh.mov_number,
   lgh.ord_hdrnumber, 
   (select cty_nmstct from city where cty_code = sstops.stp_city) 'city_a_cty_nmstct', 
   (select cty_nmstct from city where cty_code = estops.stp_city) 'city_b_cty_nmstct',
	asgn_date
INTO #tmp
FROM assetassignment, legheader lgh,
	event sevent, stops sstops, event eevent, stops estops
 WHERE asgn_type = 'TRL' 
	AND assetassignment.lgh_number = lgh.lgh_number AND 
		assetassignment.evt_number = sevent.evt_number and
		sevent.stp_number = sstops.stp_number and
		assetassignment.last_evt_number = eevent.evt_number and
		eevent.stp_number = estops.stp_number
order by asgn_date


select 
	asgn_id,
	asgn_date,
	mov_number,
	city_b_cty_nmstct 'current_trip_end_cty',

	/* Possible to have bad data with same asgn_date from same resource */
	'next_trip_start_cty' = (select top 1 city_a_cty_nmstct from #tmp t2 
								where t2.asgn_id = t.asgn_id
								and t2.asgn_date = (select min(asgn_date) from #tmp t3
														where t3.asgn_id = t.asgn_id
														and t3.asgn_date > t.asgn_date))
into #trlbeam
from #tmp t

select @glc_cnt_trlbeams = count(*) from #trlbeam
								where current_trip_end_cty <> next_trip_start_cty
								and next_trip_start_cty is not null

drop table #tmp
drop table #trlbeam

/* @glc_cnt_trlbeams END */

/* @glc_cnt_drvbeams START */
SELECT DISTINCT 
   asgn_id,
   lgh.mov_number,
   lgh.ord_hdrnumber, 
   (select cty_nmstct from city where cty_code = sstops.stp_city) 'city_a_cty_nmstct', 
   (select cty_nmstct from city where cty_code = estops.stp_city) 'city_b_cty_nmstct',
	asgn_date
INTO #tmp2
FROM assetassignment, legheader lgh,
	event sevent, stops sstops, event eevent, stops estops
 WHERE asgn_type = 'DRV' 
	AND assetassignment.lgh_number = lgh.lgh_number AND 
		assetassignment.evt_number = sevent.evt_number and
		sevent.stp_number = sstops.stp_number and
		assetassignment.last_evt_number = eevent.evt_number and
		eevent.stp_number = estops.stp_number
order by asgn_date


select 
	asgn_id,
	asgn_date,
	mov_number,
	city_b_cty_nmstct 'current_trip_end_cty',

	/* Possible to have bad data with same asgn_date from same resource */
	'next_trip_start_cty' = (select top 1 city_a_cty_nmstct from #tmp2 t2 
								where t2.asgn_id = t.asgn_id
								and t2.asgn_date = (select min(asgn_date) from #tmp2 t3
														where t3.asgn_id = t.asgn_id
														and t3.asgn_date > t.asgn_date))
into #drvbeam
from #tmp2 t

select @glc_cnt_drvbeams = count(*) from #drvbeam
								where current_trip_end_cty <> next_trip_start_cty
								and next_trip_start_cty is not null

drop table #tmp2
drop table #drvbeam

/* @glc_cnt_drvbeams END */



/* @glc_cnt_trcbeams START */
SELECT DISTINCT 
   asgn_id,
   lgh.mov_number,
   lgh.ord_hdrnumber, 
   (select cty_nmstct from city where cty_code = sstops.stp_city) 'city_a_cty_nmstct', 
   (select cty_nmstct from city where cty_code = estops.stp_city) 'city_b_cty_nmstct',
	asgn_date
INTO #tmp3
FROM assetassignment, legheader lgh,
	event sevent, stops sstops, event eevent, stops estops
 WHERE asgn_type = 'TRC' 
	AND assetassignment.lgh_number = lgh.lgh_number AND 
		assetassignment.evt_number = sevent.evt_number and
		sevent.stp_number = sstops.stp_number and
		assetassignment.last_evt_number = eevent.evt_number and
		eevent.stp_number = estops.stp_number
order by asgn_date


select 
	asgn_id,
	asgn_date,
	mov_number,
	city_b_cty_nmstct 'current_trip_end_cty',

	/* Possible to have bad data with same asgn_date from same resource */
	'next_trip_start_cty' = (select top 1 city_a_cty_nmstct from #tmp3 t2 
								where t2.asgn_id = t.asgn_id
								and t2.asgn_date = (select min(asgn_date) from #tmp3 t3
														where t3.asgn_id = t.asgn_id
														and t3.asgn_date > t.asgn_date))
into #trcbeam
from #tmp3 t

select @glc_cnt_trcbeams = count(*) from #trcbeam
								where current_trip_end_cty <> next_trip_start_cty
								and next_trip_start_cty is not null

drop table #tmp3
drop table #trcbeam

/* @glc_cnt_trcbeams END */





--select @glc_cnt_tripviews = count(*) from userobject where object = 'D_AVAILABLE_TRIPS3' and view_versiondate <> '1900-01-01 00:00:00.000'
select @glc_cnt_tripviews = count(*) from dispatchview where dv_type = 'OB'

--select @glc_cnt_resourceviews = count(*) from userobject where object = 'D_AVAILABLE_POWER3' and view_versiondate <> '1900-01-01 00:00:00.000'
select @glc_cnt_resourceviews = count(*) from dispatchview where dv_type = 'IB'

select @glc_chr_setregions = count(*) from regionheader

declare @cnt_all_legs float
declare @cnt_legs_with_reg1 float
select @cnt_all_legs = count(*) from legheader
select @cnt_legs_with_reg1 = count(*) from legheader where lgh_rstartregion1 <> 'UNK'
IF @cnt_all_legs > 0
BEGIN
set @glc_pct_org_reg1 = @cnt_legs_with_reg1 / @cnt_all_legs
END
ELSE set @glc_pct_org_reg1 = 0

select @glc_cnt_consolidated = count(*) from (select mov_number, count(*) 'Count' from orderheader group by mov_number having count(*) > 1) as cnsldt


declare @cnt_all_orders float
declare @cnt_prerated_orders float
select @cnt_all_orders = count(*) from orderheader
select @cnt_prerated_orders = count(*) from orderheader where tar_number <> 0 and tar_number is not null
IF @cnt_all_orders > 0
BEGIN
select @glc_pct_prerated = @cnt_prerated_orders / @cnt_all_orders
END
ELSE set @glc_pct_prerated = 0

declare @cnt_all_drivers float
declare @cnt_drivers_util float
select @cnt_all_drivers = count(*) from manpowerprofile where mpp_id <> 'UNKNOWN'
select @cnt_drivers_util = count(distinct asgn_id) from assetassignment where asgn_type = 'DRV'
IF @cnt_all_drivers > 0
BEGIN
select @glc_pct_drv_util = @cnt_drivers_util / @cnt_all_drivers
END
ELSE set @glc_pct_drv_util = 0


declare @cnt_all_tractors float
declare @cnt_tractors_util float
select @cnt_all_tractors = count(*) from tractorprofile where trc_number <> 'UNKNOWN'
select @cnt_tractors_util = count(distinct asgn_id) from assetassignment where asgn_type = 'TRC'
IF @cnt_all_tractors > 0
BEGIN
select @glc_pct_trc_util = @cnt_tractors_util / @cnt_all_tractors
END
ELSE set @glc_pct_trc_util = 0

declare @cnt_all_trailers float
declare @cnt_trailers_util float
select @cnt_all_trailers = count(*) from trailerprofile where trl_number <> 'UNKNOWN'
select @cnt_trailers_util = count(distinct asgn_id) from assetassignment where asgn_type = 'TRL'
IF @cnt_all_trailers > 0
BEGIN
select @glc_pct_trl_util = @cnt_trailers_util / @cnt_all_trailers
END
ELSE set @glc_pct_trl_util = 0

select @glc_cnt_ord_car_asgn = count(distinct ord_hdrnumber) from legheader where lgh_carrier <> 'UNKNOWN'


declare @cnt_bad_mileage float
select @cnt_bad_mileage = count(distinct mov_number) from stops s
				where (stp_lgh_mileage < 0 or stp_lgh_mileage is null) 
				and stp_mfh_sequence > (select min(stp_mfh_sequence) from stops s2
								where s2.lgh_number = s.lgh_number)
				and stp_event <> 'INSERV'

/* v1.3 - updated metric to include NULL mileages */
/* v1.2 - updated metric to display as %accurate miles instead of %bad mileage */
set @cnt_bad_mileage = @cnt_all_moves - @cnt_bad_mileage
IF @cnt_all_moves > 0
BEGIN
set @glc_pct_bad_mileage = @cnt_bad_mileage / @cnt_all_moves
END
ELSE set @glc_pct_bad_mileage = 0

select @glc_cnt_lgh_with_payable = count(*) from (select lgh_number, count(*) 'Count' from assetassignment where actg_type <> 'N'
													group by lgh_number having count(*) > 1) as cntpay



select lgh_number, count(*) 'Cnt' , 
	'NoAcct' = (select count(*) from assetassignment a2 where a.lgh_number = a2.lgh_number and actg_type = 'N')
into #tmpasgn
from assetassignment a
group by lgh_number

select @glc_cnt_lgh_no_payable = count(*) from #tmpasgn where Cnt = NoAcct

drop table #tmpasgn



select @glc_cnt_upd_by_tmail = count(distinct mov_number) from stops 
									where stp_arr_confirmed is not null
									or stp_dep_confirmed is not null



INSERT INTO golivecheck_vdispatch 
		(glc_rundate, glc_cnt_splittrips, glc_cnt_xdock, glc_cnt_mtmoves,
		glc_pct_moves_with_mtevent, glc_cnt_trlbeams, glc_cnt_tripviews, glc_cnt_resourceviews,
		glc_chr_setregions, glc_pct_org_reg1, glc_cnt_consolidated, glc_pct_prerated,
		glc_pct_drv_util, glc_pct_trc_util, glc_pct_trl_util, glc_cnt_ord_car_asgn,
		glc_pct_bad_mileage, glc_cnt_lgh_with_payable, glc_cnt_lgh_no_payable, glc_cnt_upd_by_tmail,
		glc_cnt_drvbeams, glc_cnt_trcbeams)
VALUES (@glc_rundate, @glc_cnt_splittrips, @glc_cnt_xdock, @glc_cnt_mtmoves,
		@glc_pct_moves_with_mtevent, @glc_cnt_trlbeams, @glc_cnt_tripviews, @glc_cnt_resourceviews,
		@glc_chr_setregions, @glc_pct_org_reg1, @glc_cnt_consolidated, @glc_pct_prerated,
		@glc_pct_drv_util, @glc_pct_trc_util, @glc_pct_trl_util, @glc_cnt_ord_car_asgn,
		@glc_pct_bad_mileage, @glc_cnt_lgh_with_payable, @glc_cnt_lgh_no_payable, @glc_cnt_upd_by_tmail,
		@glc_cnt_drvbeams, @glc_cnt_trcbeams)





/***********************************/
/* Update golivecheck_invoicing db */
/***********************************/
 
declare @glc_cnt_ivh_selection int
declare @glc_cnt_invoices int
declare @glc_cnt_active_cht int
declare @glc_pct_active_cht_nogl float
declare @glc_cnt_misc_inv int
declare @glc_cnt_supp_inv int
declare @glc_cnt_prn_inv int
declare @glc_cnt_xfr_inv int
declare @glc_pct_auto_rated_inv float
declare @glc_cnt_prn_mb int
declare @glc_cnt_inv_thrty int
declare @glc_cnt_inv_ninty int
declare @glc_cnt_inv_cm_rb int
declare @glc_pct_inv_mult_acc float
-- Added v1.2
declare @glc_pct_inv_autorated float


select @glc_cnt_ivh_selection = count(*) from invoiceselection

select @glc_cnt_invoices = count(*) from invoiceheader

select @glc_cnt_active_cht = count(*) from chargetype where cht_retired <> 'Y'

declare @cnt_active_cht float
declare @cnt_active_cht_nogl float
select @cnt_active_cht = count(*) from chargetype where cht_retired <> 'Y'
select @cnt_active_cht_nogl = count(*) from chargetype where cht_retired <> 'Y' and (cht_glnum <> '' or cht_glnum is not null)
IF @cnt_active_cht > 0
BEGIN
select @glc_pct_active_cht_nogl = @cnt_active_cht_nogl / @cnt_active_cht
END
ELSE set @glc_pct_active_cht_nogl = 0

select @glc_cnt_misc_inv = count(*) from invoiceheader where ivh_definition = 'MISC'

select @glc_cnt_supp_inv = count(*) from invoiceheader where ivh_definition = 'SUPL'

select @glc_cnt_prn_inv = count(*) from invoiceheader where ivh_invoicestatus in ('PRN', 'XFR')

select @glc_cnt_xfr_inv = count(*) from invoiceheader where ivh_invoicestatus = 'XFR'

set @glc_pct_auto_rated_inv = 0

select @glc_cnt_prn_mb = count(distinct ivh_mbnumber) from invoiceheader where ivh_mbnumber > 0 and ivh_mbstatus = 'PRN'

select @glc_cnt_inv_thrty = count(*) from invoiceheader where datediff(d,ivh_billdate,GetDate()) <= 30

select @glc_cnt_inv_ninty = count(*) from invoiceheader where datediff(d,ivh_billdate,GetDate()) <= 90

select @glc_cnt_inv_cm_rb = count(*) from invoiceheader where ivh_definition in ('CRD', 'RBIL')

declare @cnt_inv float
declare @cnt_inv_mult_acc float
select @cnt_inv = count(*) from invoiceheader
select @cnt_inv_mult_acc = (select count(*) from
								(select ivh.ivh_hdrnumber, count(*)'Count' from 
									invoicedetail ivd, invoiceheader ivh, chargetype ch
								 where ivd.ivh_hdrnumber = ivh.ivh_hdrnumber
							 	   and ch.cht_itemcode = ivd.cht_itemcode
							 	   and ch.cht_basis = 'ACC'
								  group by ivh.ivh_hdrnumber, ivh.ord_hdrnumber
								  having count(*) > 0) as cntacc)
IF @cnt_inv > 0
BEGIN
set @glc_pct_inv_mult_acc = @cnt_inv_mult_acc / @cnt_inv
END
ELSE set @glc_pct_inv_mult_acc = 0


declare @cnt_distinct_inv_orders float
declare @cnt_inv_autorated float
select @cnt_distinct_inv_orders = count(distinct ord_hdrnumber) from invoicedetail
select @cnt_inv_autorated = count(distinct ord_hdrnumber) from invoicedetail where tar_number is not null and tar_number > 0
IF @cnt_distinct_inv_orders > 0
BEGIN
select @glc_pct_inv_autorated = @cnt_inv_autorated / @cnt_distinct_inv_orders
END
ELSE set @glc_pct_inv_autorated = 0


INSERT INTO golivecheck_invoicing 
		(glc_rundate, glc_cnt_ivh_selection, glc_cnt_invoices, glc_cnt_active_cht,
		 glc_pct_active_cht_nogl, glc_cnt_misc_inv, glc_cnt_supp_inv, glc_cnt_prn_inv,
		 glc_cnt_xfr_inv, glc_pct_auto_rated_inv, glc_cnt_prn_mb, glc_cnt_inv_thrty,
		 glc_cnt_inv_ninty, glc_cnt_inv_cm_rb, glc_pct_inv_mult_acc, glc_pct_inv_autorated)
VALUES (@glc_rundate, @glc_cnt_ivh_selection, @glc_cnt_invoices, @glc_cnt_active_cht,
		@glc_pct_active_cht_nogl, @glc_cnt_misc_inv, @glc_cnt_supp_inv, @glc_cnt_prn_inv,
		@glc_cnt_xfr_inv, @glc_pct_auto_rated_inv, @glc_cnt_prn_mb, @glc_cnt_inv_thrty,
		@glc_cnt_inv_ninty, @glc_cnt_inv_cm_rb, @glc_pct_inv_mult_acc, @glc_pct_inv_autorated)





/*************************************/
/* Update golivecheck_settlements db */
/*************************************/


declare @glc_cnt_payheader int
declare @glc_cnt_future_payperiod int
declare @glc_cnt_stlmnt_sched int
declare @glc_cnt_trans_payheader int
declare @glc_cnt_closed_payheader int
declare @glc_cnt_active_pyt int
declare @glc_pct_active_pyt_nogl float
declare @glc_pay_drv_no_act_table int
declare @glc_pay_trc_no_act_table int
declare @glc_pay_car_no_act_table int
declare @glc_cnt_std_deduct int
declare @glc_cnt_pyd_std_deduct int 
declare @glc_cnt_resources_std_deduct int
declare @glc_pct_ap_trc_cld_payheader float
declare @glc_pct_pr_drv_cld_payheader float
-- Added v1.2
declare @glc_pct_stl_autorated float
--Added v1.3
declare @glc_pct_lh_pay float


select @glc_cnt_payheader = count(*) from payheader

select @glc_cnt_future_payperiod = count(*) from payschedulesdetail where psd_date > GetDate()

select @glc_cnt_stlmnt_sched = count(*) from payschedulesheader

select @glc_cnt_trans_payheader = count(*) from payheader where pyh_paystatus = 'XFR'

select @glc_cnt_closed_payheader = count(*) from payheader where pyh_paystatus = 'REL'

select @glc_cnt_active_pyt = count(*) from paytype where pyt_retired <> 'Y'

/* Update v1.2 - Changed logic to show as % Active Paytypes WITH a GL */
declare @cnt_active_pyt float
declare @cnt_active_pyt_nogl float
select @cnt_active_pyt = count(*) from paytype where pyt_retired <> 'Y'
select @cnt_active_pyt_nogl = count(*) from paytype where pyt_retired <> 'Y' and (pyt_pr_glnum <> '' or pyt_pr_glnum is not null or pyt_ap_glnum <> '' or pyt_ap_glnum is not null)
IF @cnt_active_pyt > 0
BEGIN
select @glc_pct_active_pyt_nogl = @cnt_active_pyt_nogl / @cnt_active_pyt
END
ELSE set @glc_pct_active_pyt_nogl = 0


select @glc_pay_drv_no_act_table = count(*) from manpowerprofile
									where mpp_actg_type <> 'N'
									and not exists (select asgn_id from payratekey p
														where p.asgn_id = mpp_id
														and p.asgn_type = 'DRV')

select @glc_pay_trc_no_act_table = count(*) from tractorprofile
									where trc_actg_type <> 'N'
									and not exists (select asgn_id from payratekey p
														where p.asgn_id = trc_number
														and p.asgn_type = 'TRC')

select @glc_pay_car_no_act_table = count(*) from carrier
									where car_actg_type <> 'N'
									and not exists (select asgn_id from payratekey p
														where p.asgn_id = car_id
														and p.asgn_type = 'CAR')

select @glc_cnt_std_deduct = count(*) from standingdeduction

select @glc_cnt_pyd_std_deduct = count(distinct pyt_itemcode) FROM stdmaster

select @glc_cnt_resources_std_deduct = count(distinct asgn_id) from standingdeduction

declare @cnt_ap_trc float
declare @cnt_ap_trc_cld_payheader float
select @cnt_ap_trc = count(*) from tractorprofile where trc_actg_type = 'A' and trc_status <> 'OUT'
select @cnt_ap_trc_cld_payheader = count(distinct asgn_id) from payheader where asgn_type = 'TRC' and asgn_id in (select trc_number from tractorprofile where trc_actg_type = 'A' and trc_status <> 'OUT')
IF @cnt_ap_trc > 0
BEGIN
	select @glc_pct_ap_trc_cld_payheader = @cnt_ap_trc_cld_payheader / @cnt_ap_trc
END
ELSE
	set @glc_pct_ap_trc_cld_payheader = 0


declare @cnt_pr_drv float
declare @cnt_pr_drv_cld_payheader float
select @cnt_pr_drv = count(*) from manpowerprofile where mpp_actg_type = 'P' and mpp_status <> 'OUT'
select @cnt_pr_drv_cld_payheader = count(distinct asgn_id) from payheader where asgn_type = 'DRV' and asgn_id in (select mpp_id from manpowerprofile where mpp_actg_type = 'P' and mpp_status <> 'OUT')
IF @cnt_pr_drv > 0
BEGIN
	select @glc_pct_pr_drv_cld_payheader = @cnt_pr_drv_cld_payheader / @cnt_pr_drv
END
ELSE
	set @glc_pct_pr_drv_cld_payheader = 0


declare @cnt_pyd_legs float
declare @cnt_stl_autorated float
select @cnt_pyd_legs = count(distinct lgh_number) from paydetail
select @cnt_stl_autorated = count(distinct lgh_number) from paydetail where tar_tarriffnumber > 0
IF @cnt_pyd_legs > 0
BEGIN
	select @glc_pct_stl_autorated = @cnt_stl_autorated / @cnt_pyd_legs
END
ELSE
	set @glc_pct_stl_autorated = 0




declare @cnt_cmp_trips_lh float
declare @cnt_cmp_trips_lhpay float
select @cnt_cmp_trips_lh = count (distinct lgh_number) from legheader l where lgh_outstatus = 'CMP'
select @cnt_cmp_trips_lhpay = count (distinct lgh_number) from legheader l where lgh_outstatus = 'CMP'
				and exists (select lgh_number from paydetail pyd, paytype pyt
							where pyd.lgh_number = l.lgh_number
							and pyd.pyt_itemcode = pyt.pyt_itemcode
							and pyt.pyt_basis = 'LGH')
IF @cnt_cmp_trips_lh > 0
BEGIN
	select @glc_pct_lh_pay = @cnt_cmp_trips_lhpay / @cnt_cmp_trips_lh
END
ELSE
	set @glc_pct_lh_pay = 0






INSERT INTO golivecheck_settlements 
		(glc_rundate, glc_cnt_payheader, glc_cnt_future_payperiod, glc_cnt_stlmnt_sched,
		 glc_cnt_trans_payheader, glc_cnt_closed_payheader, glc_cnt_active_pyt, glc_pct_active_pyt_nogl,
		 glc_pay_drv_no_act_table, glc_pay_trc_no_act_table, glc_pay_car_no_act_table, glc_cnt_std_deduct,
		 glc_cnt_pyd_std_deduct, glc_cnt_resources_std_deduct, glc_pct_ap_trc_cld_payheader, glc_pct_pr_drv_cld_payheader,
		 glc_pct_stl_autorated, glc_pct_lh_pay)
VALUES (@glc_rundate, @glc_cnt_payheader, @glc_cnt_future_payperiod, @glc_cnt_stlmnt_sched,
		@glc_cnt_trans_payheader, @glc_cnt_closed_payheader, @glc_cnt_active_pyt, @glc_pct_active_pyt_nogl,
		@glc_pay_drv_no_act_table, @glc_pay_trc_no_act_table, @glc_pay_car_no_act_table, @glc_cnt_std_deduct,
		@glc_cnt_pyd_std_deduct, @glc_cnt_resources_std_deduct, @glc_pct_ap_trc_cld_payheader, @glc_pct_pr_drv_cld_payheader,
		@glc_pct_stl_autorated, @glc_pct_lh_pay)





/********************************/
/* Update golivecheck_rating db */
/********************************/


declare @glc_cnt_primary_bill_rates int
declare @glc_cnt_accessorial_bill_rates int
declare @glc_cnt_lineitem_bill_rates int
declare @glc_pct_acc_li_bill_attached_primary float
declare @glc_cnt_primary_pay_rates int
declare @glc_cnt_accessorial_pay_rates int
declare @glc_cnt_lineitem_pay_rates int
declare @glc_pct_acc_pay_attached_primary float
declare @glc_cnt_bill_rates_used int
declare @glc_cnt_pay_rates_used int

select @glc_cnt_primary_bill_rates = count(distinct th.tar_number) from tariffheader th, tariffkey tk
												where th.tar_number = tk.tar_number
												and trk_primary = 'Y'

select @glc_cnt_accessorial_bill_rates = count(distinct th.tar_number) from tariffheader th, tariffkey tk
													where th.tar_number = tk.tar_number
													and trk_primary = 'N'

/* Counts Linked and Linked Line Item rates */
select @glc_cnt_lineitem_bill_rates = count(distinct th.tar_number) from tariffheader th, tariffkey tk
													where th.tar_number = tk.tar_number
													and trk_primary in ('L', 'I')

declare @cnt_billing_acc_linkedli float
declare @cnt_billing_acc_linkedli_att float
select @cnt_billing_acc_linkedli = count(distinct th.tar_number) from tariffheader th, tariffkey tk
													where th.tar_number = tk.tar_number
													 and trk_primary in ('N', 'I') and tk.trk_enddate > GetDate()
select @cnt_billing_acc_linkedli_att = count(distinct tariffkey.tar_number) from tariffkey, tariffheader, tariffaccessorial
											 where tariffheader.tar_number = tariffkey.tar_number 
  											  and tariffaccessorial.trk_number = tariffkey.trk_number
  											  and tariffkey.trk_primary in ('N', 'I') and tariffkey.trk_enddate > GetDate()
IF @cnt_billing_acc_linkedli > 0
BEGIN
set @glc_pct_acc_li_bill_attached_primary = @cnt_billing_acc_linkedli_att / @cnt_billing_acc_linkedli
END
ELSE set @glc_pct_acc_li_bill_attached_primary = 0

select @glc_cnt_primary_pay_rates = count(distinct th.tar_number) from tariffheaderstl th, tariffkey tk
												where th.tar_number = tk.tar_number
												and trk_primary = 'Y'

select @glc_cnt_accessorial_pay_rates = count(distinct th.tar_number) from tariffheaderstl th, tariffkey tk
													where th.tar_number = tk.tar_number
													and trk_primary = 'N'

select @glc_cnt_lineitem_pay_rates = count(distinct th.tar_number) from tariffheaderstl th, tariffkey tk
													where th.tar_number = tk.tar_number
													and trk_primary in ('L', 'I')

declare @cnt_pay_acc_linkedli float
declare @cnt_pay_acc_linkedli_att float
select @cnt_pay_acc_linkedli = count(distinct th.tar_number) from tariffheaderstl th, tariffkey tk
													where th.tar_number = tk.tar_number
													 and trk_primary in ('N', 'I') and tk.trk_enddate > GetDate()
select @cnt_pay_acc_linkedli_att = count(distinct tariffkey.tar_number) from tariffkey, tariffheaderstl, tariffaccessorialstl
										 where tariffheaderstl.tar_number = tariffkey.tar_number 
											  and tariffaccessorialstl.trk_number = tariffkey.trk_number
											  and tariffkey.trk_primary in ('N', 'I')  and tariffkey.trk_enddate > GetDate()
IF @cnt_pay_acc_linkedli > 0
BEGIN
set @glc_pct_acc_pay_attached_primary = @cnt_pay_acc_linkedli_att / @cnt_pay_acc_linkedli
END
ELSE set @glc_pct_acc_pay_attached_primary = 0


select @glc_cnt_bill_rates_used = count(distinct tar_number) from invoicedetail where tar_number > 0

select @glc_cnt_pay_rates_used = count(distinct tar_tarriffnumber) from paydetail where tar_tarriffnumber > 0



INSERT INTO golivecheck_rating 
		(glc_rundate, glc_cnt_primary_bill_rates, glc_cnt_accessorial_bill_rates, glc_cnt_lineitem_bill_rates,
		 glc_pct_acc_li_bill_attached_primary, glc_cnt_primary_pay_rates, glc_cnt_accessorial_pay_rates, glc_cnt_lineitem_pay_rates,
		 glc_pct_acc_pay_attached_primary, glc_cnt_bill_rates_used, glc_cnt_pay_rates_used)
VALUES (@glc_rundate, @glc_cnt_primary_bill_rates, @glc_cnt_accessorial_bill_rates, @glc_cnt_lineitem_bill_rates,
		@glc_pct_acc_li_bill_attached_primary, @glc_cnt_primary_pay_rates, @glc_cnt_accessorial_pay_rates, @glc_cnt_lineitem_pay_rates,
		@glc_pct_acc_pay_attached_primary, @glc_cnt_bill_rates_used, @glc_cnt_pay_rates_used)





/************************************/
/* Update golivecheck_fuelimport db */
/************************************/


declare @glc_cnt_fuelcards int
declare @glc_cnt_acct_code int
declare @glc_cnt_cust_code int
declare @glc_cnt_payable_no_cards int
declare @glc_cnt_fuel_purchases int
declare @glc_cnt_fuel_purchase_pyd int
declare @glc_cnt_advance_pyd int
-- Added v1.2
declare @glc_cnt_payable_drv_no_cards int
declare @glc_cnt_payable_trc_no_cards int
declare @glc_cnt_cards_no_asset int


select @glc_cnt_fuelcards = count(*) from cashcard

select @glc_cnt_acct_code = count(*) from cdacctcode

select @glc_cnt_cust_code = count(*) from cdcustcode

select @glc_cnt_payable_no_cards = count(*) from manpowerprofile 
										where mpp_actg_type <> 'N'
											and (not exists (select asgn_id from cashcard where asgn_type = 'DRV' and mpp_id = asgn_id)
											or not exists (select asgn_id from cashcard where asgn_type = 'PTO' and mpp_payto = asgn_id))


select @glc_cnt_fuel_purchases = count(*) from fuelpurchased


select @glc_cnt_fuel_purchase_pyd = count(*) from paydetail where pyt_itemcode in ('FULTRC', 'FULTRL')

select @glc_cnt_advance_pyd = count(*) from paydetail where pyt_itemcode = 'LDMNY'

select @glc_cnt_payable_drv_no_cards = count(*) from manpowerprofile 
										where mpp_actg_type <> 'N' 
										and mpp_status <> 'OUT'
										and not exists (select crd_driver from cashcard where mpp_id = crd_driver)

select @glc_cnt_payable_trc_no_cards = count(*) from tractorprofile 
										where trc_actg_type <> 'N' 
										and trc_status <> 'OUT'
										and not exists (select crd_unitnumber from cashcard where crd_unitnumber = trc_number)

select @glc_cnt_cards_no_asset = count(*) from cashcard 
									where crd_driver = 'UNKNOWN' 
									and crd_unitnumber = 'UNKNOWN'


INSERT INTO golivecheck_fuelimport 
		(glc_rundate, glc_cnt_fuelcards, glc_cnt_acct_code, glc_cnt_cust_code,
		 glc_cnt_payable_no_cards, glc_cnt_fuel_purchases, glc_cnt_fuel_purchase_pyd, glc_cnt_advance_pyd,
		 glc_cnt_payable_drv_no_cards, glc_cnt_payable_trc_no_cards, glc_cnt_cards_no_asset)
VALUES (@glc_rundate, @glc_cnt_fuelcards, @glc_cnt_acct_code, @glc_cnt_cust_code,
		@glc_cnt_payable_no_cards, @glc_cnt_fuel_purchases, @glc_cnt_fuel_purchase_pyd, @glc_cnt_advance_pyd,
		@glc_cnt_payable_drv_no_cards, @glc_cnt_payable_trc_no_cards, @glc_cnt_cards_no_asset)




/********************************/
/* Update golivecheck_edi db */
/********************************/

declare @glc_edi_cmp_invalid_output int
declare @glc_edi_trading_partners int
declare @glc_edi_incmp_214_info varchar(1) 
declare @glc_edi_210 int 
declare @glc_edi_214 int 
declare @glc_edi_997_210 int 
declare @glc_edi_997_214 int 
declare @glc_edi_204 int
declare @glc_edi_210_no_acc int 
declare @glc_edi_ref_set_not_required int 


select @glc_edi_cmp_invalid_output = count(*) from company where cmp_billto = 'Y' and cmp_invoicetype <> 'INV'

select @glc_edi_trading_partners = count(*) from edi_trading_partner where cmp_id <> 'UNKNOWN'

select @glc_edi_incmp_214_info = case when (select LEFT(UPPER(gi_string1),1) from generalinfo 
						where gi_name ='Auto214flag')='Y' 
						and (select count(*) from edi_214_profile) < 1
					then 'N'
					else 'Y'
					end

select @glc_edi_210 = count(*) FROM edi_document_tracking where edt_doctype = '210' and edt_batch_image_seq = 1

select @glc_edi_214 = count(*) from edi_document_tracking where edt_doctype = '214' and edt_batch_image_seq = 1

select @glc_edi_997_210 = count(*) from edi_document_tracking where edt_doctype = '210' and edt_batch_image_seq = 1 and edt_997_flag IS NOT NULL

select @glc_edi_997_214 = count(*) from edi_document_tracking where edt_doctype = '214' and edt_batch_image_seq = 1 and edt_997_flag IS NOT NULL

select @glc_edi_204 = count(distinct(ord_hdrnumber)) from referencenumber where ref_table = 'orderheader' and ref_type ='EDICT#'


declare @trading_partners int, @edi_accessorial int
select @trading_partners = COUNT(*) from edi_trading_partner where cmp_id <> 'UNKNOWN'
select @edi_accessorial =  COUNT(DISTINCT(cmp_id)) FROM ediaccessorial
set @glc_edi_210_no_acc = @trading_partners - @edi_accessorial

select @glc_edi_ref_set_not_required = count(*) FROM process_requirements WHERE  prq_210check = 'N'

				   


INSERT INTO golivecheck_edi 
      ( glc_rundate, glc_edi_cmp_invalid_output, glc_edi_trading_partners, glc_edi_incmp_214_info,
       	glc_edi_210, glc_edi_214, glc_edi_997_210, glc_edi_997_214,
	glc_edi_204, glc_edi_210_no_acc, glc_edi_ref_set_not_required)
VALUES(	@glc_rundate, @glc_edi_cmp_invalid_output, @glc_edi_trading_partners, @glc_edi_incmp_214_info,
       	@glc_edi_210, @glc_edi_214, @glc_edi_997_210, @glc_edi_997_214,
	@glc_edi_204, @glc_edi_210_no_acc, @glc_edi_ref_set_not_required)



GO
GRANT EXECUTE ON  [dbo].[golivecheck_run] TO [public]
GO
