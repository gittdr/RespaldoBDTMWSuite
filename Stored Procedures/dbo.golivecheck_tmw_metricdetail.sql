SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  proc [dbo].[golivecheck_tmw_metricdetail] (@cat varchar(20), @metric varchar(55))


as


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED



/* TMW SUITE METRICS */
IF @cat = 'TMW Suite'
BEGIN

	IF @metric = 'Active Tractor Count'
	BEGIN
		select * FROM tractorprofile 
			WHERE ( trc_status <> 'OUT' AND trc_status <> 'END' ) 
			AND trc_retiredate > getdate ( ) 
			AND trc_number <> 'UNKNOWN'
		  order by trc_number
	END
END




/* FILE MAINTENANCE METRICS */
IF @cat = 'File Maintenance'
BEGIN


	IF @metric = '% Cities With Valid Region 1'
	BEGIN
		select cty_code, cty_name, cty_state, cty_zip, cty_region1 from city 
			where not cty_region1 in (select distinct rgh_id from regionheader)
			AND cty_name <> 'UNKNOWN'
	END


	IF @metric = 'Companies with Missing/Incomplete Zip'
	BEGIN
		select cmp_id, cmp_name, cmp_zip
			from company where len(cmp_zip) < 5 or cmp_zip is null
			AND cmp_id <> 'UNKNOWN'
	END


	IF @metric = 'AP Drivers'
	BEGIN
		select mpp_id, mpp_lastfirst, mpp_status, mpp_actg_type
			from manpowerprofile where mpp_actg_type = 'A' and mpp_status <> 'OUT'
	END


	IF @metric = 'AP Drivers with No PayTo'
	BEGIN
		select mpp_id, mpp_lastfirst, mpp_status, mpp_actg_type
			from manpowerprofile where mpp_actg_type = 'A' and mpp_payto = 'UNKNOWN' and mpp_status <> 'OUT'
	END


	IF @metric = 'Payroll Tractors'
	BEGIN
		select trc_number, trc_status, trc_actg_type
			from tractorprofile where trc_actg_type = 'P' 
			and trc_number <> 'UNKNOWN' and trc_status <> 'OUT'
	END


	IF @metric = 'AP Tractors with No PayTo'
	BEGIN
		select trc_number, trc_status, trc_actg_type, trc_owner
			from tractorprofile where trc_actg_type = 'A' and trc_owner = 'UNKNOWN' 
			and trc_number <> 'UNKNOWN' and trc_status <> 'OUT'
	END


	IF @metric = 'Orphaned PayTos'
	BEGIN
		select pto_id, pto_fname, pto_lname, pto_status from payto
			where pto_status = 'ACT'
			and pto_id <> 'UNKNOWN'
			and not exists (select mpp_payto from manpowerprofile where mpp_payto = payto.pto_id)
			and not exists (select tpr_payto from thirdpartyprofile where tpr_payto = payto.pto_id)
			and not exists (select trc_owner from tractorprofile where trc_owner = payto.pto_id)
			and not exists (select trl_owner from trailerprofile where trl_owner = payto.pto_id)
			and not exists (select pto_id from carrier where pto_id = payto.pto_id)
	END

	If @metric = 'Carriers with No Acct Type'
	BEGIN
		select car_id, car_name, car_actg_type from carrier where car_status = 'ACT' and car_id <> 'UNKNOWN' and car_actg_type <> 'A'
	END

END


/* ORDER ENTRY METRICS */
IF @cat = 'ORDER ENTRY'
BEGIN
	IF @metric = 'Users Creating > 20 Non-Copied Orders'
	BEGIN
		select ord_bookedby, count(*) as '#Orders' 
       from orderheader where (ord_fromorder is null or ord_fromorder = 'UNKNOWN') 
                    and ord_bookedby not like '%TMW%'
                    and ord_bookedby <> 'IMPORT'
                    and ord_bookedby <> 'sa'
                    group by ord_bookedby
	END

END


/* INVOICING METRICS */
IF @cat = 'INVOICING'
BEGIN

	IF @metric = '% Active Chargetypes with GL#'
	BEGIN
		select cht_number, cht_itemcode, cht_description, cht_glnum from chargetype 
			where cht_retired <> 'Y'
                      	and (cht_glnum = '' or cht_glnum is null)
	END

END


/* SETTLEMENTS METRICS */
IF @cat = 'SETTLEMENTS'
BEGIN


	IF @metric = '% CMP Trips With a LH Pay Detail'
	BEGIN
		select lgh_number, ord_hdrnumber, lgh_driver1, lgh_tractor, lgh_carrier,
			lgh_startdate, lgh_enddate, lgh_outstatus from legheader l 
			where lgh_outstatus = 'CMP'
			and not exists (select lgh_number from paydetail pyd, paytype pyt
						where pyd.lgh_number = l.lgh_number
						and pyd.pyt_itemcode = pyt.pyt_itemcode
						and pyt.pyt_basis = 'LGH')
		  order by lgh_number
	END



	IF @metric = '% Active Paytypes with GL#'
	BEGIN
		select pyt_number, pyt_itemcode, pyt_description, pyt_pr_glnum, pyt_ap_glnum from paytype 
			where pyt_retired <> 'Y' 
			and (pyt_pr_glnum = '' or pyt_pr_glnum is null) 
			and (pyt_ap_glnum = '' or pyt_ap_glnum is null) 
	END

END

GO
GRANT EXECUTE ON  [dbo].[golivecheck_tmw_metricdetail] TO [public]
GO
