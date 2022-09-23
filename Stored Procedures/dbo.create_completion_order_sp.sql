SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[create_completion_order_sp] (@p_ord_number char(12)) 

AS

/**
 * 
 * NAME:
 * create_completion_order_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * 
 * RETURNS: NONE
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS: @p_ord_hdrnumber		int	Order Header Number To Create in Completion Table
 *
 * REVISION HISTORY:
 * 08/07/2006.01 - PTS 33397 - Dan Hudec - Created Procedure
 * 02/27/2007.01 - PTS 33397 - Frank Michels - corrected creation of completion_freightdetail
 * 05/06/2008.01 - PTS 42209 - vjh - return delivering driver rather than pickup driver
 * 05/07/2008	- Christopher Brickley -- Fixed incorrect usage of indicies on stops table.
 * 09/05/2008	44379 JD added transaction and error handling. SQL needs cleaned up but that task can wait.
 * 11/26/2009 44766 pmill display stp_arrivaldate and stp_departuredate in stops grid
 * 06/30/2010 PTS 52635 pmill/ SGB do not remove fgt_parentcmd_number and correctly set fgt_completion_subcmd_list
 * 03/31/2011 PTS 56334 SPN now on we are using referencenumber table instead of completion_referencenumber
 * 05/20/2011 PTS 57037 NQIAO
 * 08/01/2011 PTS 57698 NQIAO
 * 10/04/2011 PTS 58573 SGB 
 **/

DECLARE	@v_temp_cty_name		varchar(18),
		@v_temp_cty_state		varchar(6),
		@from_cty_nmstct		varchar(50),
		@to_cty_nmstct			varchar(50),
		@billto_cty_nmstct		varchar(50),
		@stp_cty_nmstct			varchar(50),
		@v_ord_hdrnumber		int,
		@v_ord_status			varchar(6),
		@v_cur_fgt_number		int,
		@v_max_fgt_number		int,
		@v_temp_stp_type		varchar(6),
		@v_temp_cmp_id			varchar(8),
		@v_temp_fgt_shipper		varchar(8),
		@v_temp_fgt_consignee	varchar(8),
		@v_total_time			decimal(9, 2),
		@v_ord_startdate		datetime,
		@v_ord_completiondate	datetime,
		@v_min_lgh_number		int,
		@v_shift_date			datetime,
		@v_ss_id				int,
		@v_load_date			datetime,
		@v_ord_totalmiles		int,
		@v_ord_billto			varchar(8),
		@v_temp_cmd_class		varchar(8),
		@v_temp_gross_net		char(1),
		@v_temp_billed_amt		decimal(9, 2),
		@v_delivering_driver	varchar(13),
		@v_move_number			int,
		@li_mfh					int,
		@li_lgh					int,
		@ord_odometer_start		int,		-- NQIAO 05/20/11 PTS 57037
		@ord_odometer_end		int			-- NQIAO 05/20/11 PTS 57037

SELECT	@v_ord_hdrnumber = ord_hdrnumber,
		@v_ord_status = ord_status,
		@v_move_number = mov_number,
		@v_temp_fgt_shipper = ord_shipper,
		@v_ord_billto = ord_billto,
		@v_ord_totalmiles = ord_odometer_end - ord_odometer_start
FROM	orderheader
WHERE	ord_number = @p_ord_number

--CJB - Change to use move number
SELECT	@v_min_lgh_number = min(lgh_number)
FROM	legheader
WHERE	mov_number = @v_move_number
--WHERE	mov_number = (SELECT max(mov_number) FROM orderheader
--					  WHERE	 ord_number = @p_ord_number)

-- vjh 42209 --JD modified this logic with PTS 44838 to handle consolidated orders
-- select @v_delivering_driver =  a.asgn_id
-- from orderheader o
-- join legheader l on o.ord_hdrnumber = l.ord_hdrnumber
-- join assetassignment a on l.lgh_number = a.lgh_number
-- where o.ord_hdrnumber = @v_ord_hdrnumber		
-- and a.asgn_type='DRV'
-- and a.asgn_enddate = (
-- 	select max(asgn_enddate)
-- 	from orderheader o
-- 	join legheader l on o.ord_hdrnumber = l.ord_hdrnumber
-- 	join assetassignment a on l.lgh_number = a.lgh_number
-- 	where o.ord_hdrnumber = @v_ord_hdrnumber		
-- 	and asgn_type='DRV'
-- )

-- JD 44838 begin
select @li_mfh = max(stp_mfh_sequence) from stops where ord_hdrnumber = @v_ord_hdrnumber
select @li_lgh = lgh_number from stops where ord_hdrnumber = @v_ord_hdrnumber and stp_mfh_sequence = @li_mfh
select @v_delivering_driver = asgn_id 
from assetassignment where lgh_number = @li_lgh and asgn_type = 'DRV' and asgn_controlling = 'Y'
-- JD 44838 end


--Set status
IF @v_ord_status <> 'CMP' and @v_ord_status <> 'CAN' and @v_ord_status <> 'ICO'
	SELECT @v_ord_status = 'HLD'
--Set status

--pmill changed if statement to look at completion_stops not stops to prevent any unnecessary calls to delete
--		Under normal circmstances data does not yet exist in the completion tables when this proc is called.
If (Exists (select * from completion_orderheader
	   where ord_hdrnumber = @v_ord_hdrnumber) OR exists(select * from completion_stops where ord_hdrnumber = @v_ord_hdrnumber))
       and @v_ord_hdrnumber <> 0
 BEGIN
	-- JD 44379 Added Transaction Logic and error handling
	BEGIN TRAN

	DELETE FROM completion_orderheader
	WHERE ord_hdrnumber = @v_ord_hdrnumber
	
	if @@error <> 0 --JD 44379
	begin
		rollback tran
		return -1
	end	
	--CJB - Change to use move number
	DELETE FROM completion_freightdetail
	WHERE stp_number in (select stp_number from completion_stops
			     where lgh_number in (select lgh_number from stops where mov_number = @v_move_number))

	if @@error <> 0 --JD 44379
	begin
		rollback tran
		return -2
	end	
	
	DELETE FROM completion_stops
	WHERE lgh_number in (select lgh_number from stops where mov_number = @v_move_number)

	if @@error <> 0 --JD 44379
	begin
		rollback tran
		return -3
	end	


	DELETE FROM completion_invoicedetail
	WHERE ord_hdrnumber = @v_ord_hdrnumber

	if @@error <> 0 --JD 44379
	begin
		rollback tran
		return -4
	end	



	--BEGIN PTS 56334 SPN
	--DELETE FROM completion_referencenumber
	--WHERE ord_hdrnumber = @v_ord_hdrnumber
	--END PTS 56334 SPN


	if @@error <> 0 --JD 44379
	begin
		rollback tran
		return -5
	end	


	COMMIT TRAN --JD 44379
 END

--CJB - Moved retrevial to initial retreval at the top.
--Shipper ID (FMM PTS 33397)
--SELECT  @v_temp_fgt_shipper = min(ord_shipper),
--		@v_ord_billto = min(ord_billto)
--  FROM  orderheader
-- WHERE  ord_hdrnumber = @v_ord_hdrnumber

--Shipper Name
SELECT	@v_temp_cty_name = cty_name, 
	@v_temp_cty_state = cty_state
  FROM	city
 WHERE	cty_code = (SELECT cmp_city FROM company WHERE cmp_id = @v_temp_fgt_shipper)
--FMM PTS 33397: replaced (SELECT ord_shipper from orderheader where ord_hdrnumber = @v_ord_hdrnumber) with @v_temp_fgt_shipper

SELECT	@from_cty_nmstct = @v_temp_cty_name + ', ' + @v_temp_cty_state + '/'
		
--Consignee Name
SELECT	@v_temp_cty_name = cty_name, 
	@v_temp_cty_state = cty_state
  FROM	city
 WHERE	cty_code = (SELECT cmp_city FROM company WHERE cmp_id = 
			(SELECT ord_consignee from orderheader where ord_hdrnumber = @v_ord_hdrnumber))

SELECT	@to_cty_nmstct = @v_temp_cty_name + ', ' + @v_temp_cty_state + '/'

--Bill-To Name
SELECT	@v_temp_cty_name = cty_name, 
	@v_temp_cty_state = cty_state
  FROM	city
 WHERE	cty_code = (SELECT cmp_city FROM company WHERE cmp_id = 
			(SELECT ord_billto from orderheader where ord_hdrnumber = @v_ord_hdrnumber))

SELECT	@billto_cty_nmstct = @v_temp_cty_name + ', ' + @v_temp_cty_state + '/'		

--CJB - Moved to top retrival
--SELECT	@v_ord_totalmiles = ord_odometer_end - ord_odometer_start	
--FROM	orderheader
--WHERE	ord_hdrnumber = @v_ord_hdrnumber

SELECT	@v_ord_startdate = stp_arrivaldate
FROM	stops
WHERE	lgh_number = @v_min_lgh_number
  AND	stp_mfh_sequence = 1

--CJB - Changed to @v_move_number
SELECT	@v_ord_completiondate = stp_arrivaldate
FROM	stops
WHERE	lgh_number in (select lgh_number from stops where mov_number = @v_move_number)
  AND	stp_mfh_sequence = (select max(stp_mfh_sequence) from stops
							where  lgh_number in (select lgh_number from stops where mov_number = @v_move_number))

SELECT	@v_total_time = datediff(mi, @v_ord_startdate, @v_ord_completiondate)

SELECT	@v_total_time = @v_total_time / 60

SELECT	@v_ss_id = shift_ss_id
FROM	legheader
WHERE	lgh_number = @v_min_lgh_number

If IsNull(@v_ss_id, 0) <> 0
 BEGIN
	SELECT	@v_shift_date = ss_date
	FROM	shiftschedules
	WHERE	ss_id = @v_ss_id
 END
ELSE
 BEGIN
	SELECT	@v_shift_date = @v_ord_startdate
 END

SELECT	@v_load_date = stp_arrivaldate
FROM	stops 
WHERE	lgh_number = @v_min_lgh_number
AND		stp_mfh_sequence = (select min(stp_mfh_sequence) from stops
							where  lgh_number = @v_min_lgh_number
							and    stp_type = 'PUP')	


BEGIN TRAN -- 44379 JD 
--Create Orderheader
INSERT INTO completion_orderheader(
	ord_company, 
	ord_number, 
	ord_customer, 
	ord_bookdate, 
	ord_bookedby, 
	ord_status, 
	ord_originpoint, 
	ord_destpoint, 
	ord_invoicestatus, 
	ord_origincity,			--10
	ord_destcity, 
	ord_originstate, 
	ord_deststate, 
	ord_originregion1, 
	ord_destregion1, 
	ord_supplier, 
	ord_billto, 
	ord_startdate, 
	ord_completiondate, 
	ord_revtype1,			--20
	ord_revtype2, 
	ord_revtype3, 
	ord_revtype4, 
	ord_totalweight, 
	ord_totalpieces, 
	ord_totalmiles, 
	ord_totalcharge, 
	ord_currency, 
	ord_currencydate, 
	ord_totalvolume,		--30
	ord_hdrnumber, 
	ord_refnum, 
	ord_invoicewhole, 
	ord_remark, 
	ord_shipper, 
	ord_consignee, 
	ord_pu_at, 
	ord_dr_at, 
	ord_originregion2, 
	ord_originregion3,		--40
	ord_originregion4, 
	ord_destregion2, 
	ord_destregion3, 
	ord_destregion4, 
	mfh_hdrnumber, 
	ord_priority, 
	mov_number, 
	tar_tarriffnumber, 
	tar_number, 
	tar_tariffitem,			--50
	ord_contact, 
	ord_showshipper, 
	ord_showcons, 
	ord_subcompany, 
	ord_lowtemp, 
	ord_hitemp, 
	ord_quantity, 
	ord_rate, 
	ord_charge, 
	ord_rateunit,			--60
	ord_unit, 
	trl_type1, 
	ord_driver1, 
	ord_driver2, 
	ord_tractor, 
	ord_trailer, 
	ord_length, 
	ord_width, 
	ord_height, 
	ord_lengthunit,			--70
	ord_widthunit, 
	ord_heightunit, 
	ord_reftype, 
	cmd_code, 
	ord_description, 
	ord_terms, 
	cht_itemcode, 
	ord_origin_earliestdate, 
	ord_origin_latestdate, 
	ord_odmetermiles,		--80
	ord_stopcount, 
	ord_dest_earliestdate, 
	ord_dest_latestdate, 
	ref_sid, 
	ref_pickup, 
	ord_cmdvalue, 
	ord_accessorial_chrg, 
	ord_availabledate, 
	ord_miscqty, 
	ord_tempunits,			--90
	ord_datetaken, 
	ord_totalweightunits, 
	ord_totalvolumeunits, 
	ord_totalcountunits, 
	ord_loadtime, 
	ord_unloadtime, 
	ord_drivetime, 
	ord_rateby, 
	ord_quantity_type,
	ord_thirdpartytype1,	--100
	ord_thirdpartytype2, 
	ord_charge_type, 
	ord_bol_printed, 
	ord_fromorder, 
	ord_mintemp, 
	ord_maxtemp, 
	ord_distributor, 
	opt_trc_type4, 
	opt_trl_type4, 
	ord_cod_amount,			--110
	appt_init, 
	appt_contact, 
	ord_ratingquantity, 
	ord_ratingunit, 
	ord_booked_revtype1, 
	ord_hideshipperaddr, 
	ord_hideconsignaddr, 
	ord_trl_type2, 
	ord_trl_type3, 
	ord_trl_type4,			--120
	ord_tareweight, 
	ord_grossweight, 
	ord_mileagetable, 
	ord_allinclusivecharge, 
	ord_extrainfo1, 
	ord_extrainfo2, 
	ord_extrainfo3, 
	ord_extrainfo4, 
	ord_extrainfo5, 
	ord_extrainfo6,			--130
	ord_extrainfo7, 
	ord_extrainfo8, 
	ord_extrainfo9, 
	ord_extrainfo10, 
	ord_extrainfo11, 
	ord_extrainfo12, 
	ord_extrainfo13, 
	ord_extrainfo14, 
	ord_extrainfo15, 
	ord_rate_type,			--140
	ord_barcode, 
	ord_broker, 
	ord_stlquantity, 
	ord_stlunit, 
	ord_stlquantity_type, 
	ord_fromschedule, 
	ord_schedulebatch, 
	ord_trlrentinv, 
	ord_revenue_pay_fix, 
	ord_revenue_pay,		--150
	ord_reserved_number, 
	ord_customs_document, 
	ord_noautosplit, 
	ord_noautotransfer, 
	ord_totalloadingmeters, 
	ord_totalloadingmetersunit, 
	ord_charge_type_lh, 
	ord_complete_stamp, 
	last_updateby, 
	last_updatedate,		--160
	ord_entryport, 
	ord_exitport, 
	ord_mileage_adj_pct,
	ord_commodities_weight, 
	ord_intermodal, 
	ord_order_source, 
	ord_dimfactor, 
	external_id, 
	external_type, 
	ord_UnlockKey,			--170
	ord_TrlConfiguration, 
	ord_origin_zip, 
	ord_dest_zip, 
	ord_rate_mileagetable, 
	ord_toll_cost, 
	ord_toll_cost_update_date, 
	ord_raildest, 
	ord_railpoolid, 
	ord_trailer2, 
	ord_route,				--180
	ord_route_effc_date, 
	ord_route_exp_date, 
	ord_odmetermiles_mtid, 
	ord_edipurpose, 
	ord_ediuseraction,
	ord_edistate, 
	ord_no_recalc_miles, 
	ord_editradingpartner, 
	ord_edideclinereason, 
	ord_miscdate1,			--190
	ord_carrier,
	ord_completion_odometer_start,
	ord_completion_odometer_end,
	ord_completion_pickup_count,
	ord_completion_drop_count,
	from_cmp_name,
	from_cty_nmstct,
	to_cmp_name,
	to_cty_nmstct,
	ord_completion_batch_eligible,	--200
	ord_completion_batch_status,
	ord_completion_shift_date,
	ord_completion_shift_id,
	ord_completion_bill_miles,
	ord_completion_pay_miles,
	ord_completion_total_time,
	ord_completion_agent,
	billto_cmp_name,
	billto_cty_nmstct,
	ord_completion_loaddate)		--210
SELECT	ord_company, 
	ord_number, 
	ord_customer, 
	ord_bookdate, 
	ord_bookedby, 
	@v_ord_status, 
	ord_originpoint, 
	ord_destpoint, 
	ord_invoicestatus, 
	ord_origincity,			--10
	ord_destcity, 
	ord_originstate, 
	ord_deststate, 
	ord_originregion1, 
	ord_destregion1, 
	ord_supplier, 
	ord_billto, 
	@v_ord_startdate, 
	@v_ord_completiondate, 
	ord_revtype1,			--20
	ord_revtype2, 
	ord_revtype3, 
	ord_revtype4, 
	ord_totalweight, 
	ord_totalpieces, 
	@v_ord_totalmiles,  --ord_totalmiles
	ord_totalcharge, 
	ord_currency, 
	ord_currencydate, 
	ord_totalvolume,		--30
	ord_hdrnumber, 
	ord_refnum, 
	ord_invoicewhole, 
	ord_remark, 
	ord_shipper, 
	ord_consignee, 
	ord_pu_at, 
	ord_dr_at, 
	ord_originregion2, 
	ord_originregion3,		--40
	ord_originregion4, 
	ord_destregion2, 
	ord_destregion3, 
	ord_destregion4, 
	mfh_hdrnumber, 
	ord_priority, 
	mov_number, 
	tar_tarriffnumber, 
	tar_number, 
	tar_tariffitem,			--50
	ord_contact, 
	ord_showshipper, 
	ord_showcons, 
	ord_subcompany, 
	ord_lowtemp, 
	ord_hitemp, 
	ord_quantity, 
	ord_rate, 
	ord_charge, 
	ord_rateunit,			--60
	ord_unit, 
	trl_type1, 
	@v_delivering_driver, -- vjh 42209
	ord_driver2, 
	ord_tractor, 
	ord_trailer, 
	ord_length, 
	ord_width, 
	ord_height, 
	ord_lengthunit,			--70
	ord_widthunit, 
	ord_heightunit, 
	ord_reftype, 
	cmd_code, 
	ord_description, 
	ord_terms, 
	cht_itemcode, 
	ord_origin_earliestdate, 
	ord_origin_latestdate, 
	ord_odmetermiles,		--80
	ord_stopcount, 
	ord_dest_earliestdate, 
	ord_dest_latestdate, 
	ref_sid, 
	ref_pickup, 
	ord_cmdvalue, 
	ord_accessorial_chrg, 
	ord_availabledate, 
	ord_miscqty, 
	ord_tempunits, 	--90
	ord_datetaken, 
	ord_totalweightunits, 
	ord_totalvolumeunits, 
	ord_totalcountunits, 
	ord_loadtime, 
	ord_unloadtime, 
	ord_drivetime, 
	ord_rateby, 
	ord_quantity_type, 
	ord_thirdpartytype1, --100
	ord_thirdpartytype2, 
	ord_charge_type, 
	ord_bol_printed, 
	ord_fromorder, 
	ord_mintemp, 
	ord_maxtemp, 
	ord_distributor, 
	opt_trc_type4, 
	opt_trl_type4, 
	ord_cod_amount, --110
	appt_init, 
	appt_contact, 
	ord_ratingquantity, 
	ord_ratingunit, 
	ord_booked_revtype1, 
	ord_hideshipperaddr, 
	ord_hideconsignaddr, 
	ord_trl_type2, 
	ord_trl_type3, 
	ord_trl_type4, --120
	ord_tareweight, 
	ord_grossweight, 
	ord_mileagetable, 
	ord_allinclusivecharge, 
	ord_extrainfo1, 
	ord_extrainfo2, 
	ord_extrainfo3, 
	ord_extrainfo4, 
	ord_extrainfo5, 
	ord_extrainfo6, --130
	ord_extrainfo7, 
	ord_extrainfo8, 
	ord_extrainfo9, 
	ord_extrainfo10, 
	ord_extrainfo11, 
	ord_extrainfo12, 
	ord_extrainfo13, 
	ord_extrainfo14, 
	ord_extrainfo15, 
	ord_rate_type, --140
	ord_barcode, 
	ord_broker, 
	ord_stlquantity, 
	ord_stlunit, 
	ord_stlquantity_type, 
	ord_fromschedule, 
	ord_schedulebatch, 
	ord_trlrentinv, 
	ord_revenue_pay_fix, 
	ord_revenue_pay, --150
	ord_reserved_number, 
	ord_customs_document, 
	ord_noautosplit, 
	ord_noautotransfer, 
	ord_totalloadingmeters, 
	ord_totalloadingmetersunit, 
	ord_charge_type_lh, 
	ord_complete_stamp, 
	last_updateby, 
	last_updatedate, --160
	ord_entryport, 
	ord_exitport, 
	ord_mileage_adj_pct,
	ord_commodities_weight, 
	ord_intermodal, 
	ord_order_source, 
	ord_dimfactor, 
	external_id, 
	external_type, 
	ord_UnlockKey, --170
	ord_TrlConfiguration, 
	ord_origin_zip, 
	ord_dest_zip, 
	ord_rate_mileagetable, 
	ord_toll_cost, 
	ord_toll_cost_update_date, 
	ord_raildest, 
	ord_railpoolid, 
	ord_trailer2, 
	ord_route, --180
	ord_route_effc_date, 
	ord_route_exp_date, 
	ord_odmetermiles_mtid, 
	ord_edipurpose, 
	ord_ediuseraction,
	ord_edistate, 
	ord_no_recalc_miles, 
	ord_editradingpartner, 
	ord_edideclinereason, 
	ord_miscdate1, --190
	ord_carrier,
	ord_odometer_start,					-- ord_completion_odometer_start
	ord_odometer_end,					-- ord_completion_odometer_end
	(SELECT count(*) FROM stops WHERE stp_type = 'PUP' 
	 AND stops.mov_number = @v_move_number), 				-- ord_completion_pickup_count -- CJB - changed to mov_number
	(SELECT count(*) FROM stops WHERE stp_type = 'DRP' 
	 AND stops.mov_number = @v_move_number), 				-- ord_completion_drop_count -- CJB - changed to mov_number
	(SELECT	cmp_name FROM company WHERE cmp_id = orderheader.ord_shipper), 	-- from_cmp_name
	@from_cty_nmstct,							-- from_cty_nmstct
	(SELECT	cmp_name FROM company WHERE cmp_id = orderheader.ord_consignee), -- to_cmp_name
	@to_cty_nmstct,								-- to_cty_nmstct
 	'', 										-- ord_completion_batch_eligible   --200
 	'', 										-- ord_completion_batch_status
	@v_shift_date,								-- ord_completion_shift_date,
	'',											-- ord_completion_shift_id,
	0,											-- ord_completion_bill_miles,
	0,											-- ord_completion_pay_miles,
	@v_total_time,								-- ord_completion_total_time,
	ord_thirdpartytype1,						-- ord_completion_agent,
 	(SELECT	cmp_name FROM company WHERE cmp_id = orderheader.ord_billto),	-- billto_cmp_name
 	@billto_cty_nmstct,							-- billto_cty_nmstct
	@v_load_date								-- ord_completion_loaddate   --210
FROM 	orderheader
WHERE	ord_hdrnumber = @v_ord_hdrnumber

	if @@error <> 0 --JD 44379
	begin
		rollback tran
		return -50
	end	

--Create Orderheader

--Create Stops
--CJB - Changed join so nested query could be removed to reduce the number of reads.
INSERT INTO completion_stops(
	ord_hdrnumber, 
	stp_number, 
	cmp_id, 
	stp_region1, 
	stp_region2, 
	stp_region3, 
	stp_city, 
	stp_state, 
	stp_schdtearliest, 
	stp_origschdt, 
	stp_arrivaldate, 
	stp_departuredate, 
	stp_reasonlate, 
	stp_schdtlatest, 
	lgh_number, 
	mfh_number, 
	stp_type, 
	stp_paylegpt, 
	shp_hdrnumber, 
	stp_sequence, 
	stp_region4, 
	stp_lgh_sequence, 
	trl_id, 
	stp_mfh_sequence, 
	stp_event, 
	stp_mfh_position, 
	stp_lgh_position, 
	stp_mfh_status, 
	stp_lgh_status, 
	stp_ord_mileage, 
	stp_lgh_mileage, 
	stp_mfh_mileage, 
	mov_number, 
	stp_loadstatus, 
	stp_weight, 
	stp_weightunit, 
	cmd_code, 
	stp_description,
	stp_count, 
	stp_countunit, 
	cmp_name, 
	stp_comment, 
	stp_status, 
	stp_reftype, 
	stp_refnum, 
	stp_reasonlate_depart, 
	stp_screenmode, 
	skip_trigger, 
	stp_volume, 
	stp_volumeunit, 
	stp_dispatched_sequence, 
	stp_arr_confirmed, 
	stp_dep_confirmed, 
	stp_type1, 
	stp_redeliver, 
	stp_osd, 
	stp_pudelpref, 
	stp_phonenumber, 
	stp_delayhours, 
	stp_ooa_mileage, 
	stp_zipcode, 
	stp_OOA_stop, 
	stp_address, 
	stp_transfer_stp, 
	stp_phonenumber2, 
	stp_address2, 
	stp_contact, 
	stp_custpickupdate, 
	stp_custdeliverydate, 
	stp_podname, 
	stp_cmp_close, 
	stp_activitystart_dt, 
	stp_activityend_dt, 
	stp_departure_status, 
	stp_eta, 
	stp_etd, 
	stp_transfer_type,
	stp_trip_mileage, 
	stp_stl_mileage_flag, 
	tmp_evt_number, 
	tmp_fgt_number, 
	stp_pallets_in, 
	stp_pallets_out, 
	stp_pallets_received, 
	stp_pallets_shipped, 
	stp_pallets_rejected, 
	psh_number, 
	stp_advreturnempty, 
	stp_country, 
	stp_loadingmeters, 
	stp_loadingmetersunit, 
	stp_cod_amount, 
	stp_cod_currency, 
	stp_extra_count, 
	stp_extra_weight, 
	stp_alloweddet, 
	stp_detstatus, 
	stp_gfc_arr_radius, 
	stp_gfc_arr_radiusunits, 
	stp_gfc_arr_timeout, 
	stp_tmstatus, 
	stp_reasonlate_text, 
	stp_reasonlate_depart_text, 
	stp_est_drv_time, 
	stp_est_activity, 
	nlm_time_diff, 
	stp_lgh_mileage_mtid, 
	stp_count2, 
	stp_countunit2, 
	stp_ord_toll_cost, 
	stp_ord_mileage_mtid, 
	stp_ooa_mileage_mtid, 
	last_updateby, 
	last_updatedate, 
	last_updatebydepart, 
	last_updatedatedepart, 
	stp_unload_paytype,
	stp_completion_odometer,
	stp_completion_driver1,
	stp_completion_driver2,
	stp_completion_tractor,
	stp_completion_trailer,
	stp_completion_shift_date,
	stp_completion_shift_id,
	city_cty_nmstct)
SELECT	stops.ord_hdrnumber, 
	stops.stp_number,  
	cmp_id, 
	stp_region1, 
	stp_region2, 
	stp_region3, 
	stp_city, 
	stp_state, 
	stp_schdtearliest,  --stp_arrivaldate 44766 pmill put schdtearliest back - changing stops grid to show arrivaldate
	stp_origschdt, 
	stp_arrivaldate, 
	stp_departuredate, 
	stp_reasonlate, 
	stp_schdtlatest,  --stp_departuredate 44766 pmill put schdtlatest back - changing stops grid to show departuredate
	lgh_number, 
	mfh_number, 
	stp_type, 
	stp_paylegpt, 
	shp_hdrnumber, 
	stp_sequence, 
	stp_region4, 
	stp_lgh_sequence, 
	trl_id, 
	stp_mfh_sequence, 
	stp_event, 
	stp_mfh_position, 
	stp_lgh_position, 
	stp_mfh_status, 
	stp_lgh_status, 
	stp_ord_mileage, 
	stp_lgh_mileage, 
	stp_mfh_mileage, 
	mov_number, 
	stp_loadstatus, 
	stp_weight, 
	stp_weightunit, 
	cmd_code, 
	stp_description,
	stp_count, 
	stp_countunit, 
	cmp_name, 
	stp_comment, 
	stp_status, 
	stp_reftype, 
	stp_refnum, 
	stp_reasonlate_depart, 
	stp_screenmode, 
	stops.skip_trigger, 
	stp_volume, 
	stp_volumeunit, 
	stp_dispatched_sequence, 
	stp_arr_confirmed, 
	stp_dep_confirmed, 
	stp_type1, 
	stp_redeliver, 
	stp_osd, 
	stp_pudelpref, 
	stp_phonenumber, 
	stp_delayhours, 
	stp_ooa_mileage, 
	stp_zipcode, 
	stp_OOA_stop, 
	stp_address, 
	stops.stp_transfer_stp, 
	stp_phonenumber2, 
	stp_address2, 
	stp_contact, 
	stp_custpickupdate, 
	stp_custdeliverydate, 
	stp_podname, 
	stp_cmp_close, 
	stp_activitystart_dt, 
	stp_activityend_dt, 
	stp_departure_status, 
	stp_eta, 
	stp_etd, 
	stp_transfer_type,
	stp_trip_mileage, 
	stp_stl_mileage_flag, 
	tmp_evt_number, 
	tmp_fgt_number, 
	stp_pallets_in, 
	stp_pallets_out, 
	stp_pallets_received, 
	stp_pallets_shipped, 
	stp_pallets_rejected, 
	psh_number, 
	stp_advreturnempty, 
	stp_country, 
	stp_loadingmeters, 
	stp_loadingmetersunit, 
	stp_cod_amount, 
	stp_cod_currency, 
	stp_extra_count, 
	stp_extra_weight, 
	stp_alloweddet, 
	stp_detstatus, 
	stp_gfc_arr_radius, 
	stp_gfc_arr_radiusunits, 
	stp_gfc_arr_timeout, 
	stp_tmstatus, 
	stp_reasonlate_text, 
	stp_reasonlate_depart_text, 
	stp_est_drv_time, 
	stp_est_activity, 
	nlm_time_diff, 
	stp_lgh_mileage_mtid, 
	stp_count2, 
	stp_countunit2, 
	stp_ord_toll_cost, 
	stp_ord_mileage_mtid, 
	stp_ooa_mileage_mtid, 
	last_updateby, 
	last_updatedate, 
	last_updatebydepart, 
	last_updatedatedepart, 
	stp_unload_paytype,
	evt_hubmiles,	-- stp_completion_odometer,
	evt_driver1,	-- stp_completion_driver1,
	evt_driver2,	-- stp_completion_driver2,
	evt_tractor,	-- stp_completion_tractor,
	evt_trailer1,	-- stp_completion_trailer,
	'',									-- stp_completion_shift_date,
	'',									-- stp_completion_shift_id,
	(SELECT cty_name + ', ' + cty_state + '/' FROM city WHERE cty_code =	-- city_cty_nmstct
		(SELECT cmp_city from company where cmp_id = stops.cmp_id))
FROM 	stops
inner join event on event.stp_number = stops.stp_number and evt_sequence = 1
--WHERE	lgh_number in (select lgh_number from stops where ord_hdrnumber = @v_ord_hdrnumber)
WHERE	mov_number = @v_move_number
--WHERE	ord_hdrnumber = @v_ord_hdrnumber
ORDER BY stp_mfh_sequence
--Create Stops

	if @@error <> 0 --JD 44379
	begin
		rollback tran
		return -51
	end	

--Create Freight
INSERT INTO completion_freightdetail(
	fgt_number, 
	cmd_code, 
	fgt_weight, 
	fgt_weightunit,
	fgt_description, 
	stp_number, 
	fgt_count, 
	fgt_countunit, 
	fgt_volume, 
	fgt_volumeunit, 
	fgt_lowtemp, 
	fgt_hitemp, 
	fgt_sequence, 
	fgt_length, 
	fgt_lengthunit, 
	fgt_height, 
	fgt_heightunit, 
	fgt_width, 
	fgt_widthunit,  
	fgt_reftype, 
	fgt_refnum, 
	fgt_quantity, 
	fgt_rate, 
	fgt_charge, 
	fgt_rateunit, 
	cht_itemcode, 
	cht_basisunit, 
	fgt_unit, 
	skip_trigger, 
	tare_weight, 
	tare_weightunit, 
	fgt_pallets_in, 
	fgt_pallets_out, 
	fgt_pallets_on_trailer, 
	fgt_carryins1,
	fgt_carryins2, 
	fgt_stackable, 
	fgt_ratingquantity, 
	fgt_ratingunit, 
	fgt_quantity_type, 
	fgt_ordered_count, 
	fgt_ordered_weight, 
	tar_number, 
	tar_tariffnumber, 
	tar_tariffitem, 
	fgt_charge_type, 
	fgt_rate_type, 
	fgt_loadingmeters, 
	fgt_loadingmetersunit, 
	fgt_additionl_description, 
	fgt_specific_flashpoint, 
	fgt_specific_flashpoint_unit, 
	fgt_ordered_volume, 
	fgt_ordered_loadingmeters, 
	fgt_pallet_type, 
	cpr_density, 
	scm_subcode, 
	fgt_terms, 
	fgt_consignee, 
	fgt_shipper, 
	fgt_leg_origin, 
	fgt_leg_dest, 
	fgt_count2, 
	fgt_count2unit, 
	fgt_bolid, 
	fgt_bol_status, 
	fgt_osdreason, 
	fgt_osdquantity, 
	fgt_osdunit, 
	fgt_osdcomment, 
	fgt_packageunit,
	fgt_completion_grossamt,
	fgt_completion_netamt,
 	fgt_completion_grossnet_flag,
	fgt_completion_billedamt,
	fgt_completion_supplier_id,
	fgt_completion_supplier_name,
	fgt_completion_supplier_ctyst,
	fgt_completion_bol,
	fgt_completion_subcmd_list,
	fgt_parentcmd_number,
	fgt_completion_sequence,
	fgt_completion_accountof)
SELECT 	freightdetail.fgt_number, 
	freightdetail.cmd_code, 
	freightdetail.fgt_weight, 
	freightdetail.fgt_weightunit,
	freightdetail.fgt_description, 
	freightdetail.stp_number, 
	freightdetail.fgt_count, 
	freightdetail.fgt_countunit, 
	freightdetail.fgt_volume, 
	freightdetail.fgt_volumeunit, 
	freightdetail.fgt_lowtemp, 
	freightdetail.fgt_hitemp, 
	freightdetail.fgt_sequence, 
	freightdetail.fgt_length, 
	freightdetail.fgt_lengthunit, 
	freightdetail.fgt_height, 
	freightdetail.fgt_heightunit, 
	freightdetail.fgt_width, 
	freightdetail.fgt_widthunit,  
	freightdetail.fgt_reftype, 
	freightdetail.fgt_refnum, 
	freightdetail.fgt_quantity, 
	freightdetail.fgt_rate, 
	freightdetail.fgt_charge, 
	freightdetail.fgt_rateunit, 
	freightdetail.cht_itemcode, 
	freightdetail.cht_basisunit, 
	freightdetail.fgt_volumeunit,			--freightdetail.fgt_unit, 
	freightdetail.skip_trigger, 
	freightdetail.tare_weight, 
	freightdetail.tare_weightunit, 
	freightdetail.fgt_pallets_in, 
	freightdetail.fgt_pallets_out, 
	freightdetail.fgt_pallets_on_trailer, 
	freightdetail.fgt_carryins1,
	freightdetail.fgt_carryins2, 
	freightdetail.fgt_stackable, 
	freightdetail.fgt_ratingquantity, 
	freightdetail.fgt_ratingunit, 
	freightdetail.fgt_quantity_type, 
	freightdetail.fgt_ordered_count, 
	freightdetail.fgt_ordered_weight, 
	freightdetail.tar_number, 
	freightdetail.tar_tariffnumber, 
	freightdetail.tar_tariffitem, 
	freightdetail.fgt_charge_type, 
	freightdetail.fgt_rate_type, 
	freightdetail.fgt_loadingmeters, 
	freightdetail.fgt_loadingmetersunit, 
	freightdetail.fgt_additionl_description, 
	freightdetail.fgt_specific_flashpoint, 
	freightdetail.fgt_specific_flashpoint_unit, 
	freightdetail.fgt_ordered_volume, 
	freightdetail.fgt_ordered_loadingmeters, 
	freightdetail.fgt_pallet_type, 
	freightdetail.cpr_density, 
	freightdetail.scm_subcode, 
	freightdetail.fgt_terms, 
	stops.cmp_id, --FMM PTS 33397: freightdetail.fgt_consignee, 
	IsNull(freightdetail.fgt_shipper, @v_temp_fgt_shipper), --FMM PTS 33397: freightdetail.fgt_shipper, --DPH PTS 40094
	freightdetail.fgt_leg_origin, 
	freightdetail.fgt_leg_dest, 
	freightdetail.fgt_count2, 
	freightdetail.fgt_count2unit, 
	freightdetail.fgt_bolid, 
	freightdetail.fgt_bol_status, 
	freightdetail.fgt_osdreason, 
	freightdetail.fgt_osdquantity, 
	freightdetail.fgt_osdunit, 
	freightdetail.fgt_osdcomment, 
	freightdetail.fgt_packageunit,
	freightdetail.fgt_volume,		-- freightdetail.fgt_completion_grossamt,
	freightdetail.fgt_volume2,		-- freightdetail.fgt_completion_netamt,
	'G',							-- freightdetail.fgt_completion_grossnet_flag,
	freightdetail.fgt_volume,		-- freightdetail.fgt_completion_billedamt,
	fgt_supplier,					-- freightdetail.fgt_completion_supplier_id,
	(select cmp_name from company where cmp_id = IsNull(fgt_supplier, 'UNKNOWN')),			-- freightdetail.fgt_completion_supplier_name,
	'UNKNOWN',						-- freightdetail.fgt_completion_supplier_ctyst,
	'',								-- freightdetail.fgt_completion_bol,
	'',								-- freightdetail.fgt_completion_subcmd_list,
	freightdetail.fgt_parentcmd_fgt_number,
	freightdetail.fgt_display_sequence,
	freightdetail.fgt_accountof
FROM 	freightdetail,
	stops
WHERE	stops.stp_number = freightdetail.stp_number
  --AND	stops.ord_hdrnumber = @v_ord_hdrnumber
  AND	stops.mov_number = @v_move_number
  AND	freightdetail.cmd_code <> 'UNKNOWN'
  AND	freightdetail.cmd_code <> 'UNK'
--Create Freight
	if @@error <> 0 --JD 44379
	begin
		rollback tran
		return -52
	end	


	COMMIT TRAN --JD 44379
	
-- NQIAO 05/20/11 PTS 57037 <start> - ord_completion_odometer_start and ord_completion_odometer_end fields in table completion_orderheader
-- should reflect the first and last stops' stp_completion_odometer values in the completion_stops table.
SELECT	@ord_odometer_start = stp_completion_odometer
FROM	completion_stops
WHERE	mov_number = @v_move_number
AND		stp_mfh_sequence = (select min(stp_mfh_sequence) from completion_stops where mov_number = @v_move_number)

SELECT	@ord_odometer_end = stp_completion_odometer
FROM	completion_stops
WHERE	mov_number = @v_move_number
AND		stp_mfh_sequence = (select max(stp_mfh_sequence) from completion_stops where mov_number = @v_move_number)

UPDATE	completion_orderheader
SET		ord_completion_odometer_start = @ord_odometer_start,
		ord_completion_odometer_end = @ord_odometer_end,
		ord_totalmiles = @ord_odometer_end - @ord_odometer_start	-- NQIAO 08/01/11 PTS 57698
WHERE	ord_hdrnumber = @v_ord_hdrnumber
-- NQIAO 05/20/11 PTS 57037 <end>	
	

--CJB - Changed to movenumber
UPDATE	completion_freightdetail
SET		completion_freightdetail.fgt_completion_subcmd_list	 = 'Y'
--pmill / SGB 52635 just because there is a fgt_parentcmd_number doesn't make it a splash blend
--WHERE	completion_freightdetail.stp_number in (select stp_number from stops 
--												where stops.mov_number = @v_move_number) 
--  AND	completion_freightdetail.fgt_parentcmd_number > 0
-- Set Splash Blend indicator on Pickup freight 
  WHERE completion_freightdetail.fgt_parentcmd_number in (select fgt_parentcmd_number from completion_freightdetail cf
															group by cf.fgt_parentcmd_number
															having count(cf.fgt_parentcmd_number) > 1)
														   and stp_number in (select stp_number from stops 
																where stops.mov_number = @v_move_number)
AND	isnull(completion_freightdetail.fgt_parentcmd_number,0) > 0		-- PTS 58573 SGB

--pmill 52635 do not null out fgt_parentcmd_number
--CJB - Changed to movenumber
--UPDATE	completion_freightdetail
--SET		fgt_parentcmd_number = null
--WHERE	fgt_parentcmd_number in (select fgt_parentcmd_number from completion_freightdetail 
--									group by fgt_parentcmd_number
--									having count(fgt_parentcmd_number) = 1)
--   AND	stp_number in (select stp_number from stops where stops.mov_number = @v_move_number) 

--These are parent rows of a splash blend
--CJB - Changed to movenumber
--UPDATE	completion_freightdetail
--SET		completion_freightdetail.fgt_parentcmd_number = 0,
--		completion_freightdetail.fgt_shipper = 'UNKNOWN'
--WHERE	completion_freightdetail.fgt_completion_subcmd_list <> 'Y' 
--  AND	completion_freightdetail.fgt_number in (select fgt_parentcmd_number from completion_freightdetail
--														   where stp_number in (select stp_number from stops 
--																where stops.mov_number = @v_move_number))
--pmill  52635 just because there is a fgt_parentcmd_number doesn't make it a splash blend
UPDATE	completion_freightdetail
SET		completion_freightdetail.fgt_parentcmd_number = 0,
		completion_freightdetail.fgt_shipper = 'UNKNOWN'
WHERE	completion_freightdetail.fgt_completion_subcmd_list <> 'Y' 
  AND	completion_freightdetail.fgt_number in (select fgt_parentcmd_number from completion_freightdetail
															group by fgt_parentcmd_number
															having count(fgt_parentcmd_number) > 1)
														   and stp_number in (select stp_number from stops 
																where stops.mov_number = @v_move_number)
--CJB - Changed to movenumber
--44766 pmill if we delete freightdetail records for PUP they just get recreated.  Leave them
--DELETE	completion_freightdetail
--WHERE	completion_freightdetail.stp_number in (select stp_number from stops 
--													where stops.mov_number = @v_move_number
--												  and stops.stp_type = 'PUP') 
--  AND	IsNull(completion_freightdetail.fgt_parentcmd_number, 0) = 0

SELECT	@v_cur_fgt_number = min(completion_freightdetail.fgt_number)
FROM	completion_freightdetail, completion_stops
WHERE	completion_stops.stp_number = completion_stops.stp_number
  AND	completion_stops.ord_hdrnumber = @v_ord_hdrnumber

SELECT	@v_max_fgt_number = max(completion_freightdetail.fgt_number)
FROM	completion_freightdetail, completion_stops
WHERE	completion_stops.stp_number = completion_stops.stp_number
  AND	completion_stops.ord_hdrnumber = @v_ord_hdrnumber

WHILE	@v_cur_fgt_number <= @v_max_fgt_number
 BEGIN
	SELECT	@v_temp_cmd_class = commodityclass2.ccl_code
	FROM	commodityclass2, commodity
	WHERE	commodityclass2.ccl_code = commodity.cmd_class2
	AND		commodity.cmd_code = (select cmd_code from freightdetail where fgt_number = @v_cur_fgt_number)

   If (select IsNull(fgt_parentcmd_fgt_number, 0) from freightdetail where fgt_number = @v_cur_fgt_number) > 0
	BEGIN
--	   SELECT	@v_temp_fgt_consignee = s.cmp_id
--		FROM	stops s, freightdetail f1, freightdetail f2
--		WHERE	f1.fgt_parentcmd_fgt_number = f2.fgt_number
--		  AND	f2.stp_number = s.stp_number
--		  AND	f1.fgt_number = @v_cur_fgt_number

--		UPDATE	completion_freightdetail
--		   SET	fgt_consignee = @v_temp_fgt_consignee
--		 WHERE	fgt_number = @v_cur_fgt_number

		UPDATE	completion_freightdetail
		   SET	fgt_consignee = 'UNKNOWN'
		 WHERE	fgt_number = @v_cur_fgt_number
	END

	IF exists (select * from billto_cmd_billingqty_relations where billto_id = @v_ord_billto and cmd_class = @v_temp_cmd_class) 
		SELECT	@v_temp_gross_net = IsNull(gross_net_flag, 'G')
		FROM	billto_cmd_billingqty_relations
		WHERE	billto_id = @v_ord_billto
		  AND	cmd_class = @v_temp_cmd_class
	ELSE
		SELECT	@v_temp_gross_net = 'G'

	IF @v_temp_gross_net = 'N'
		SELECT	@v_temp_billed_amt = fgt_completion_netamt
		FROM	completion_freightdetail
		WHERE	fgt_number = @v_cur_fgt_number
	ELSE
		SELECT	@v_temp_billed_amt = fgt_completion_grossamt
		FROM	completion_freightdetail
		WHERE	fgt_number = @v_cur_fgt_number

	UPDATE	completion_freightdetail
	SET		fgt_completion_grossnet_flag = @v_temp_gross_net,
			fgt_completion_billedamt = @v_temp_billed_amt
	WHERE	fgt_number = @v_cur_fgt_number

	SELECT	@v_cur_fgt_number = min(completion_freightdetail.fgt_number)
	FROM	completion_freightdetail, completion_stops
	WHERE	completion_stops.stp_number = completion_freightdetail.stp_number
	  AND	completion_stops.ord_hdrnumber = @v_ord_hdrnumber
      AND	completion_stops.ord_hdrnumber <> 0
	  AND	completion_freightdetail.fgt_number > @v_cur_fgt_number
 END

--Create Invoicedetails
INSERT INTO completion_invoicedetail(
	ivh_hdrnumber, 
	ivd_number, 
	stp_number, 
	ivd_description, 
	cht_itemcode, 
	ivd_quantity, 
	ivd_rate, 
	ivd_charge, 
	ivd_taxable1, 
	ivd_taxable2, 
	ivd_taxable3, 
	ivd_taxable4, 
	ivd_unit, 
	cur_code, 
	ivd_currencydate,
	ivd_glnum, 
	ord_hdrnumber, 
	ivd_type, 
	ivd_rateunit, 
	ivd_billto, 
	ivd_itemquantity, 
	ivd_subtotalptr, 
	ivd_allocatedrev, 
	ivd_sequence, 
	ivd_invoicestatus, 
	mfh_hdrnumber, 
	ivd_refnum, 
	cmd_code, 
	cmp_id, 
	ivd_distance, 
	ivd_distunit, 
	ivd_wgt, 
	ivd_wgtunit, 
	ivd_count, 
	ivd_countunit, 
	evt_number, 
	ivd_reftype, 
	ivd_volume, 
	ivd_volunit, 
	ivd_orig_cmpid, 
	ivd_payrevenue, 
	ivd_sign, 
	ivd_length, 
	ivd_lengthunit, 
	ivd_width, 
	ivd_widthunit, 
	ivd_height, 
	ivd_heightunit, 
	ivd_exportstatus, 
	cht_basisunit, 
	ivd_remark, 
	tar_number, 
	tar_tariffnumber, 
	tar_tariffitem, 
	ivd_fromord, 
	ivd_zipcode, 
	ivd_quantity_type, 
	cht_class, 
	ivd_mileagetable, 
	ivd_charge_type, 
	ivd_trl_rent, 
	ivd_trl_rent_start, 
	ivd_trl_rent_end, 
	ivd_rate_type, 
	cht_lh_min, 
	cht_lh_rev, 
	cht_lh_stl, 
	cht_lh_rpt, 
	cht_rollintolh, 
	cht_lh_prn, 
	fgt_number, 
	ivd_paylgh_number, 
	ivd_tariff_type, 
	ivd_taxid, 
	ivd_ordered_volume, 
	ivd_ordered_loadingmeters, 
	ivd_ordered_count,
	ivd_ordered_weight, 
	ivd_loadingmeters, 
	ivd_loadingmeters_unit,
	last_updateby, 
	last_updatedate, 
	ivd_revtype1, 
	ivd_hide, 
	ivd_baserate,  
	ivd_oradjustment, 
	ivd_cbadjustment, 
	ivd_fsc, 
	ivd_splitbillratetype, 
	ivd_rawcharge, 
	ivd_bolid, 
	ivd_shared_wgt,
	ivd_completion_odometer,
	ivd_completion_billable_flag,
	ivd_completion_payable_flag,
	ivd_completion_drv_id,
	ivd_completion_drv_name,
	cht_description)
SELECT	invoicedetail.ivh_hdrnumber, 
	invoicedetail.ivd_number, 
	invoicedetail.stp_number, 
	invoicedetail.ivd_description, 
	invoicedetail.cht_itemcode, 
	invoicedetail.ivd_quantity, 
	invoicedetail.ivd_rate, 
	invoicedetail.ivd_charge, 
	invoicedetail.ivd_taxable1, 
	invoicedetail.ivd_taxable2, 
	invoicedetail.ivd_taxable3, 
	invoicedetail.ivd_taxable4, 
	invoicedetail.ivd_unit, 
	invoicedetail.cur_code, 
	invoicedetail.ivd_currencydate,
	invoicedetail.ivd_glnum, 
	invoicedetail.ord_hdrnumber, 
	invoicedetail.ivd_type, 
	invoicedetail.ivd_rateunit, 
	invoicedetail.ivd_billto, 
	invoicedetail.ivd_itemquantity, 
	invoicedetail.ivd_subtotalptr, 
	invoicedetail.ivd_allocatedrev, 
	invoicedetail.ivd_sequence, 
	invoicedetail.ivd_invoicestatus, 
	invoicedetail.mfh_hdrnumber, 
	invoicedetail.ivd_refnum, 
	invoicedetail.cmd_code, 
	invoicedetail.cmp_id, 
	invoicedetail.ivd_distance, 
	invoicedetail.ivd_distunit, 
	invoicedetail.ivd_wgt, 
	invoicedetail.ivd_wgtunit, 
	invoicedetail.ivd_count, 
	invoicedetail.ivd_countunit, 
	invoicedetail.evt_number, 
	invoicedetail.ivd_reftype, 
	invoicedetail.ivd_volume, 
	invoicedetail.ivd_volunit, 
	invoicedetail.ivd_orig_cmpid, 
	invoicedetail.ivd_payrevenue, 
	invoicedetail.ivd_sign, 
	invoicedetail.ivd_length, 
	invoicedetail.ivd_lengthunit, 
	invoicedetail.ivd_width, 
	invoicedetail.ivd_widthunit, 
	invoicedetail.ivd_height, 
	invoicedetail.ivd_heightunit, 
	invoicedetail.ivd_exportstatus, 
	invoicedetail.cht_basisunit, 
	invoicedetail.ivd_remark, 
	invoicedetail.tar_number, 
	invoicedetail.tar_tariffnumber, 
	invoicedetail.tar_tariffitem, 
	invoicedetail.ivd_fromord, 
	invoicedetail.ivd_zipcode, 
	invoicedetail.ivd_quantity_type, 
	invoicedetail.cht_class, 
	invoicedetail.ivd_mileagetable, 
	invoicedetail.ivd_charge_type, 
	invoicedetail.ivd_trl_rent, 
	invoicedetail.ivd_trl_rent_start, 
	invoicedetail.ivd_trl_rent_end, 
	invoicedetail.ivd_rate_type, 
	invoicedetail.cht_lh_min, 
	invoicedetail.cht_lh_rev, 
	invoicedetail.cht_lh_stl, 
	invoicedetail.cht_lh_rpt, 
	invoicedetail.cht_rollintolh, 
	invoicedetail.cht_lh_prn, 
	invoicedetail.fgt_number, 
	invoicedetail.ivd_paylgh_number, 
	invoicedetail.ivd_tariff_type, 
	invoicedetail.ivd_taxid, 
	invoicedetail.ivd_ordered_volume, 
	invoicedetail.ivd_ordered_loadingmeters, 
	invoicedetail.ivd_ordered_count,
	invoicedetail.ivd_ordered_weight, 
	invoicedetail.ivd_loadingmeters, 
	invoicedetail.ivd_loadingmeters_unit,
	invoicedetail.last_updateby, 
	invoicedetail.last_updatedate, 
	invoicedetail.ivd_revtype1, 
	invoicedetail.ivd_hide, 
	invoicedetail.ivd_baserate,  
	invoicedetail.ivd_oradjustment, 
	invoicedetail.ivd_cbadjustment, 
	invoicedetail.ivd_fsc, 
	invoicedetail.ivd_splitbillratetype, 
	invoicedetail.ivd_rawcharge, 
	invoicedetail.ivd_bolid, 
 	invoicedetail.ivd_shared_wgt,
	'',		-- invoicedetail.ivd_completion_odometer
	'',		-- invoicedetail.ivd_completion_billable_flag
	'',		-- invoicedetail.ivd_completion_payable_flag
	'UNK',		-- invoicedetail.ivd_completion_drv_id
	'UNKNOWN',	-- invoicedetail.ivd_completion_drv_name
	(SELECT cht_description FROM chargetype 
		WHERE cht_itemcode = invoicedetail.cht_itemcode)	-- invoicedetail.cht_description
FROM	invoicedetail
WHERE	invoicedetail.ord_hdrnumber = @v_ord_hdrnumber
--Create Invoicedetails

--BEGIN PTS 56334 SPN
--Create Referencenumbers
--INSERT INTO completion_referencenumber(
--	ref_tablekey, 
--	ref_type, 
--	ref_number, 
--	ref_typedesc, 
--	ref_sequence, 
--	ord_hdrnumber,  
--	ref_table, 
--	ref_sid, 
--	ref_pickup, 
--	last_updateby, 
--	last_updatedate)
--SELECT 	ref_tablekey, 
--	ref_type, 
--	ref_number, 
--	ref_typedesc, 
--	ref_sequence, 
--	ord_hdrnumber,  
--	ref_table, 
--	ref_sid, 
--	ref_pickup, 
--	last_updateby, 
--	last_updatedate
--FROM 	referencenumber
--WHERE	ord_hdrnumber = @v_ord_hdrnumber
--Create Referencenumbers
--END PTS 56334 SPN

RETURN 1 -- JD 44379
GO
GRANT EXECUTE ON  [dbo].[create_completion_order_sp] TO [public]
GO
