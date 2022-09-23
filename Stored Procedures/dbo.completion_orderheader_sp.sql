SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[completion_orderheader_sp] (@p_ordnum varchar(12), @p_hdrnumber int, 
				       @p_barcode varchar(30), @p_fgtref varchar(30), @p_dispatchref varchar(30)) 

AS

/**
 * 
 * NAME:
 * completion_orderheader_sp
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
 * PARAMETERS: NONE
 *
 * REVISION HISTORY:
 * 6/28/2006.01 ? PTS33397 - Dan Hudec ? Created Procedure
 * 12/12/2008 pmill PTS45329 When order is retrieved by barcode and it doesn't exist in order completion, create it
 * 09/21/2011 SGB PTS 59106 Remove invalid refernce numbers
 **/

DECLARE	@v_ord_hdrnumber				int,
		@v_notes_count 					int,
		@v_ref_display_1				varchar(50),
		@v_ref_display_2				varchar(50),
		@v_ref_display_3				varchar(50),
		@v_ref_display_4				varchar(50),
		@v_ref_value_1					varchar(30),
		@v_ref_value_2					varchar(30),
		@v_ref_value_3					varchar(30),
		@v_ref_value_4					varchar(30),
		@v_gi_ref1						varchar(60),
		@v_gi_ref2						varchar(60),
		@v_gi_ref3						varchar(60),
		@v_gi_ref4						varchar(60),
		@v_mov_number					int,
		@v_origin_cmpid					varchar(8),  
		@v_dest_cmpid					varchar(8),  
		@v_billto_cmpid					varchar(8),  
		@v_thirdparty					varchar(8),
		@v_ivh_count					int,
		@v_pyd_count					int,
		@v_ord_completion_ivhpyd_count	int,
		@v_refnum_count					int,
		@v_ord_completion_bill_miles	money,
		@v_ord_completion_pay_miles		money,
		@v_ord_batchratestatus			char(1),
		@v_ord_batchrateeligibility		char(1),
		@v_lgh_number					int,
		@v_lgh_status					varchar(6)

If @p_ordnum <> '0' and not exists (SELECT * from completion_orderheader
	       WHERE  ord_number = @p_ordnum) and not exists (SELECT * from orderheader WHERE ord_number = @p_ordnum)
	return

If exists (SELECT * from orderheader WHERE ord_number = @p_ordnum) and @p_ordnum <> '0'
 BEGIN
	SELECT	@v_lgh_number = min(lgh_number)
	FROM	legheader
	WHERE	mov_number = (SELECT max(mov_number) FROM orderheader
						  WHERE	 ord_number = @p_ordnum)

	SELECT	@v_lgh_status = lgh_outstatus
	FROM	legheader
	WHERE	lgh_number = @v_lgh_number
 END
	
IF IsNull(@v_lgh_status, 'CMP') <> 'CMP'
	Return
		
If not exists (SELECT * from completion_orderheader
	       WHERE  ord_number = @p_ordnum) and @p_ordnum <> '0'
 BEGIN
		EXEC create_completion_order_sp @p_ordnum 
 END

--45329 SELECT @v_ord_hdrnumber = ''
IF @p_ordnum <> '0'
	--If we were passed a valid order number, then the order should be in the order completion tables now
 BEGIN
	SELECT	@v_ord_hdrnumber = ISNULL(max(ord_hdrnumber), 0)
	FROM	completion_orderheader
	WHERE	ord_number = @p_ordnum
	
	--PTS 59106 SGB Clean up incorrect BOL refernce numbers
	delete referencenumber 
	where ord_hdrnumber = @v_ord_hdrnumber
	and ref_type = 'BL#'
	and ref_tablekey not in 
	(select fgt_number from stops s
	join freightdetail f on 
	f.stp_number = s.stp_number
	where s.ord_hdrnumber = @v_ord_hdrnumber)
	and ref_table = 'freightdetail'

	--45329 we don't have an ord_hdrnumber, so the order must not have been copied successfully to the order completion tables
	IF @v_ord_hdrnumber = 0 
		RETURN
 END

ELSE  --An order number was not passed in. Try to find it based on reference number passed in.

--45329 These queries all assumed that the order was already in the order completion tables,
--  but that may not be the case if we are searching for the order by a reference number.  
--  Look in the main reference number table first, then try the completion tables (in case the order was created in order completion)
	BEGIN  --search by reference number
		IF @p_barcode <> ''
			 BEGIN
				SELECT	@v_ord_hdrnumber = ISNULL(max(ord_hdrnumber),0)
				FROM	referencenumber
				WHERE	ref_type = 'BCD#'
				  AND	ref_number = @p_barcode	
				  AND 	ref_table = 'orderheader'

				--BEGIN PTS 56334 SPN
				--IF @v_ord_hdrnumber = 0 
				--	BEGIN
				--		SELECT	@v_ord_hdrnumber = ISNULL(max(ord_hdrnumber),0)
				--		FROM	completion_referencenumber with(index(dk_completion_referencenumber_ref_number))
				--		WHERE	ref_type = 'BCD#'
				--		  AND	ref_number = @p_barcode	
				--		  AND 	ref_table = 'orderheader'
				--	END
				--END PTS 56334 SPN
			 END
			
		IF @p_fgtref <> ''
			 BEGIN
				SELECT	@v_ord_hdrnumber = ISNULL(max(ord_hdrnumber),0)
				FROM	referencenumber
				WHERE	ref_type = 'BL#'
				  AND	ref_number = @p_fgtref
				  AND	ref_table = 'freightdetail'

				--BEGIN PTS 56334 SPN
				--IF @v_ord_hdrnumber = 0 
				--	BEGIN
				--		SELECT	@v_ord_hdrnumber = ISNULL(max(ord_hdrnumber),0)
				--		FROM	completion_referencenumber with(index(dk_completion_referencenumber_ref_number))
				--		WHERE	ref_type = 'BL#'
				--		  AND	ref_number = @p_fgtref
				--		  AND	ref_table = 'freightdetail'
				--	END
				--END PTS 56334 SPN

			 END
			
		IF @p_dispatchref <> ''
			 BEGIN
				SELECT	@v_ord_hdrnumber = ISNULL(max(ord_hdrnumber),0)
				FROM	referencenumber
				WHERE	ref_type = 'DIS#'
				  AND	ref_number = @p_dispatchref
				  AND	ref_table = 'orderheader'

				--BEGIN PTS 56334 SPN
				--IF @v_ord_hdrnumber = 0 
				--	BEGIN
				--		SELECT	@v_ord_hdrnumber = ISNULL(max(ord_hdrnumber),0)
				--		FROM	completion_referencenumber with(index(dk_completion_referencenumber_ref_number))
				--		WHERE	ref_type = 'DIS#'
				--		  AND	ref_number = @p_dispatchref
				--		  AND	ref_table = 'orderheader'
				--	END
				--END PTS 56334 SPN
			 END
		
		--45329 commented
		--IF @v_ord_hdrnumber = ''
		-- BEGIN
		--	SELECT	@v_ord_hdrnumber = max(ord_hdrnumber)
		--	FROM	completion_orderheader
		--	WHERE	ord_number = @p_ordnum
		-- END


		--Check lgh_outstatus for refnum lookups
		--45329IF @p_ordnum = '0'
		IF @v_ord_hdrnumber <> 0 
			BEGIN
				If exists (SELECT * from orderheader WHERE ord_hdrnumber = @v_ord_hdrnumber)
				 BEGIN
					SELECT	@v_lgh_number = min(lgh_number)
					FROM	legheader
					WHERE	mov_number = (SELECT max(mov_number) FROM orderheader
										  WHERE	 ord_hdrnumber = @v_ord_hdrnumber)
			
					SELECT	@v_lgh_status = lgh_outstatus
					FROM	legheader
					WHERE	lgh_number = @v_lgh_number
				 END
				
				IF IsNull(@v_lgh_status, 'CMP') <> 'CMP'
					Return
			
				--45329 when retrieving by something other than order number, copy the order to order completion if it doesn't exist
				If not exists (SELECT * from completion_orderheader
							 WHERE  ord_hdrnumber = @v_ord_hdrnumber)
				 BEGIN
						SELECT @p_ordnum = (SELECT ISNULL(ord_number,0) FROM orderheader WHERE ord_hdrnumber = @v_ord_hdrnumber)
						IF @p_ordnum <> '0'
							EXEC create_completion_order_sp @p_ordnum 
						ELSE
							RETURN
				 END
			
			END
			--Check lgh_outstatus for refnum lookups
--		ELSE --didn't find the order by reference number
--			RETURN

	END -- search by reference number


--Calculate Notes 
SELECT	@v_mov_number = mov_number,  
		@v_origin_cmpid = ord_originpoint,  
		@v_dest_cmpid = ord_destpoint,  
		@v_billto_cmpid = ord_billto,  
		@v_thirdparty = ord_thirdpartytype1  
FROM	orderheader  
WHERE   ord_hdrnumber = @v_ord_hdrnumber  
   
EXEC @v_notes_count = d_notes_check_sp  1,  
   @v_mov_number,  
   @v_ord_hdrnumber,
   '',   
   '',   
           '',   
           '',   
           '',   
           '',   
           '',  
   '',   
   @v_dest_cmpid,  
   @v_billto_cmpid,  
   0,  
   '',  
   '',  
   0  
--Calculate Notes


--BEGIN PTS 56334 SPN
--SELECT	@v_refnum_count = COUNT(*)  
--FROM	completion_referencenumber, orderheader  
--WHERE	orderheader.ord_hdrnumber = @v_ord_hdrnumber AND  
--		completion_referencenumber.ref_table = 'orderheader' AND  
--		completion_referencenumber.ref_tablekey = orderheader.ord_hdrnumber  
SELECT	@v_refnum_count = COUNT(*)  
FROM	referencenumber, orderheader  
WHERE	orderheader.ord_hdrnumber = @v_ord_hdrnumber AND  
		referencenumber.ref_table = 'orderheader' AND  
		referencenumber.ref_tablekey = orderheader.ord_hdrnumber  
--END PTS 56334 SPN

SELECT	@v_ivh_count = count(*)
FROM	invoiceheader
WHERE	ord_hdrnumber = @v_ord_hdrnumber

SELECT	@v_pyd_count = count(*)
FROM	paydetail
WHERE	ord_hdrnumber = @v_ord_hdrnumber

SELECT	@v_ord_completion_ivhpyd_count = @v_ivh_count + @v_pyd_count

SELECT	@v_gi_ref1 = gi_string1, 
	@v_gi_ref2 = gi_string2, 
	@v_gi_ref3 = gi_string3, 
	@v_gi_ref4 = gi_string4
FROM	generalinfo
WHERE	gi_name = 'OrdCompletionRefDisplay'

--BEGIN PTS 56334 SPN
--SELECT	@v_ref_value_1 = ref_number
--FROM	completion_referencenumber
--WHERE	ref_table = 'orderheader'
--  AND	ref_type = @v_gi_ref1
--  AND	ord_hdrnumber = @v_ord_hdrnumber
--  AND	ref_sequence = (SELECT	min(ref_sequence)
--						FROM	completion_referencenumber
--						WHERE	ref_table = 'orderheader'
--						  AND	ref_type = @v_gi_ref1
--						  AND	ord_hdrnumber = @v_ord_hdrnumber)
SELECT	@v_ref_value_1 = ref_number
FROM	referencenumber
WHERE	ref_table = 'orderheader'
  AND	ref_type = @v_gi_ref1
  AND	ord_hdrnumber = @v_ord_hdrnumber
  AND	ref_sequence = (SELECT	min(ref_sequence)
						FROM	referencenumber
						WHERE	ref_table = 'orderheader'
						  AND	ref_type = @v_gi_ref1
						  AND	ord_hdrnumber = @v_ord_hdrnumber)
--END PTS 56334 SPN

--BEGIN PTS 56334 SPN
--SELECT	@v_ref_value_2 = ref_number
--FROM	completion_referencenumber
--WHERE	ref_table = 'orderheader'
--  AND	ref_type = @v_gi_ref2
--AND	ord_hdrnumber = @v_ord_hdrnumber
--  AND	ref_sequence = (SELECT	min(ref_sequence)
--						FROM	completion_referencenumber
--						WHERE	ref_table = 'orderheader'
--						  AND	ref_type = @v_gi_ref2
--						  AND	ord_hdrnumber = @v_ord_hdrnumber)
SELECT	@v_ref_value_2 = ref_number
FROM	referencenumber
WHERE	ref_table = 'orderheader'
  AND	ref_type = @v_gi_ref2
AND	ord_hdrnumber = @v_ord_hdrnumber
  AND	ref_sequence = (SELECT	min(ref_sequence)
						FROM	referencenumber
						WHERE	ref_table = 'orderheader'
						  AND	ref_type = @v_gi_ref2
						  AND	ord_hdrnumber = @v_ord_hdrnumber)
--END PTS 56334 SPN

--BEGIN PTS 56334 SPN
--SELECT	@v_ref_value_3 = ref_number
--FROM	completion_referencenumber
--WHERE	ref_table = 'orderheader'
--  AND	ref_type = @v_gi_ref3
--  AND	ord_hdrnumber = @v_ord_hdrnumber
--  AND	ref_sequence = (SELECT	min(ref_sequence)
--						FROM	completion_referencenumber
--						WHERE	ref_table = 'orderheader'
--						  AND	ref_type = @v_gi_ref3
--						  AND	ord_hdrnumber = @v_ord_hdrnumber)
SELECT	@v_ref_value_3 = ref_number
FROM	referencenumber
WHERE	ref_table = 'orderheader'
  AND	ref_type = @v_gi_ref3
  AND	ord_hdrnumber = @v_ord_hdrnumber
  AND	ref_sequence = (SELECT	min(ref_sequence)
						FROM	referencenumber
						WHERE	ref_table = 'orderheader'
						  AND	ref_type = @v_gi_ref3
						  AND	ord_hdrnumber = @v_ord_hdrnumber)
--END PTS 56334 SPN

--BEGIN PTS 56334 SPN
--SELECT	@v_ref_value_4 = ref_number
--FROM	completion_referencenumber
--WHERE	ref_table = 'orderheader'
--  AND	ref_type = @v_gi_ref4
--  AND	ord_hdrnumber = @v_ord_hdrnumber
--  AND	ref_sequence = (SELECT	min(ref_sequence)
--						FROM	completion_referencenumber
--						WHERE	ref_table = 'orderheader'
--						  AND	ref_type = @v_gi_ref4
--						  AND	ord_hdrnumber = @v_ord_hdrnumber)
SELECT	@v_ref_value_4 = ref_number
FROM	referencenumber
WHERE	ref_table = 'orderheader'
  AND	ref_type = @v_gi_ref4
  AND	ord_hdrnumber = @v_ord_hdrnumber
  AND	ref_sequence = (SELECT	min(ref_sequence)
						FROM	referencenumber
						WHERE	ref_table = 'orderheader'
						  AND	ref_type = @v_gi_ref4
						  AND	ord_hdrnumber = @v_ord_hdrnumber)
--END PTS 56334 SPN

If exists (SELECT * from orderheader
	       WHERE  ord_hdrnumber = @v_ord_hdrnumber) and @v_ord_hdrnumber <> '0'
 BEGIN
	SELECT	@v_ord_completion_bill_miles = ord_billmiles,
			@v_ord_completion_pay_miles	= ord_paymiles,
			@v_ord_batchratestatus = ord_batchratestatus,
			@v_ord_batchrateeligibility = ord_batchrateeligibility
	FROM	orderheader
	WHERE	ord_hdrnumber = @v_ord_hdrnumber
 END

SELECT	ord_company, 
	ord_number, 
	ord_customer, 
	ord_bookdate, 
	ord_bookedby, 
	ord_status, 
	ord_originpoint, 
	ord_destpoint, 
	ord_invoicestatus, 
	ord_origincity, 
	ord_destcity, 
	ord_originstate, 
	ord_deststate, 
	ord_originregion1, 
	ord_destregion1, 
	ord_supplier, 
	ord_billto, 
	ord_startdate, 
	ord_completiondate, 
	ord_revtype1, 
	ord_revtype2, 
	ord_revtype3, 
	ord_revtype4, 
	ord_totalweight, 
	ord_totalpieces, 
	ord_totalmiles, 
	ord_totalcharge, 
	ord_currency, 
	ord_currencydate, 
	ord_totalvolume, 
	ord_hdrnumber, 
	ord_refnum, 
	ord_invoicewhole, 
	ord_remark, 
	ord_shipper, 
	ord_consignee, 
	ord_pu_at, 
	ord_dr_at, 
	ord_originregion2, 
	ord_originregion3, 
	ord_originregion4, 
	ord_destregion2, 
	ord_destregion3, 
	ord_destregion4, 
	mfh_hdrnumber, 
	ord_priority, 
	mov_number, 
	tar_tarriffnumber, 
	tar_number, 
	tar_tariffitem, 
	ord_contact, 
	ord_showshipper, 
	ord_showcons, 
	ord_subcompany, 
	ord_lowtemp, 
	ord_hitemp, 
	ord_quantity, 
	ord_rate, 
	ord_charge, 
	ord_rateunit, 
	ord_unit, 
	trl_type1, 
	ord_driver1, 
	ord_driver2, 
	ord_tractor, 
	ord_trailer, 
	ord_length, 
	ord_width, 
	ord_height, 
	ord_lengthunit, 
	ord_widthunit, 
	ord_heightunit, 
	ord_reftype, 
	cmd_code, 
	ord_description, 
	ord_terms, 
	cht_itemcode, 
	ord_origin_earliestdate, 
	ord_origin_latestdate, 
	ord_odmetermiles, 
	ord_stopcount, 
	ord_dest_earliestdate, 
	ord_dest_latestdate, 
	ref_sid, 
	ref_pickup, 
	ord_cmdvalue, 
	ord_accessorial_chrg, 
	ord_availabledate, 
	ord_miscqty, 
	ord_tempunits, 
	ord_datetaken, 
	ord_totalweightunits, 
	ord_totalvolumeunits, 
	ord_totalcountunits, 
	ord_loadtime, 
	ord_unloadtime, 
	ord_drivetime, 
	ord_rateby, 
	ord_quantity_type, 
	ord_thirdpartytype1, 
	ord_thirdpartytype2, 
	ord_charge_type, 
	ord_bol_printed, 
	ord_fromorder, 
	ord_mintemp, 
	ord_maxtemp, 
	ord_distributor, 
	opt_trc_type4, 
	opt_trl_type4, 
	ord_cod_amount, 
	appt_init, 
	appt_contact, 
	ord_ratingquantity, 
	ord_ratingunit, 
	ord_booked_revtype1, 
	ord_hideshipperaddr, 
	ord_hideconsignaddr, 
	ord_trl_type2, 
	ord_trl_type3, 
	ord_trl_type4, 
	ord_tareweight, 
	ord_grossweight, 
	ord_mileagetable, 
	ord_allinclusivecharge, 
	ord_extrainfo1, 
	ord_extrainfo2, 
	ord_extrainfo3, 
	ord_extrainfo4, 
	ord_extrainfo5, 
	ord_extrainfo6, 
	ord_extrainfo7, 
	ord_extrainfo8, 
	ord_extrainfo9, 
	ord_extrainfo10, 
	ord_extrainfo11, 
	ord_extrainfo12, 
	ord_extrainfo13, 
	ord_extrainfo14, 
	ord_extrainfo15, 
	ord_rate_type, 
	ord_barcode, 
	ord_broker, 
	ord_stlquantity, 
	ord_stlunit, 
	ord_stlquantity_type, 
	ord_fromschedule, 
	ord_schedulebatch, 
	ord_trlrentinv, 
	ord_revenue_pay_fix, 
	ord_revenue_pay, 
	ord_reserved_number, 
	ord_customs_document, 
	ord_noautosplit, 
	ord_noautotransfer, 
	ord_totalloadingmeters, 
	ord_totalloadingmetersunit, 
	ord_charge_type_lh, 
	ord_complete_stamp, 
	last_updateby, 
	last_updatedate, 
	ord_entryport, 
	ord_exitport, 
	ord_mileage_adj_pct,
	ord_commodities_weight, 
	ord_intermodal, 
	ord_order_source, 
	ord_dimfactor, 
	external_id, 
	external_type, 
	ord_UnlockKey, 
	ord_TrlConfiguration, 
	ord_origin_zip, 
	ord_dest_zip, 
	ord_rate_mileagetable, 
	ord_toll_cost, 
	ord_toll_cost_update_date, 
	ord_raildest, 
	ord_railpoolid, 
	ord_trailer2, 
	ord_route, 
	ord_route_effc_date, 
	ord_route_exp_date, 
	ord_odmetermiles_mtid, 
	ord_edipurpose, 
	ord_ediuseraction,
	ord_edistate, 
	ord_no_recalc_miles, 
	ord_editradingpartner, 
	ord_edideclinereason, 
	ord_miscdate1, 
	ord_carrier,
	ord_completion_odometer_start,
	ord_completion_odometer_end,
	ord_completion_pickup_count,
	ord_completion_drop_count,
	@v_notes_count notes_count,
	@v_ref_display_1 ref_display_1,
	@v_ref_display_2 ref_display_2,
	@v_ref_display_3 ref_display_3,
	@v_ref_display_4 ref_display_4,
	@v_ref_value_1 ref_value_1,
	@v_ref_value_2 ref_value_2,
	@v_ref_value_3 ref_value_3,
	@v_ref_value_4 ref_value_4,
	from_cmp_name,
	from_cty_nmstct,
	to_cmp_name,
	to_cty_nmstct,
	@v_ord_batchrateeligibility		ord_completion_batch_eligible,
	@v_ord_batchratestatus			ord_completion_batch_status,
	ord_completion_shift_date,
	ord_completion_shift_id,
	@v_ord_completion_bill_miles	ord_completion_bill_miles,
	@v_ord_completion_pay_miles		ord_completion_pay_miles,
	ord_completion_total_time,
	ord_completion_agent,
	billto_cmp_name,
	billto_cty_nmstct,
	ord_completion_loaddate,
	(select	max(userlabelname) from	labelfile where labeldefinition = 'RevType1') reftype1_1,
	(select	max(userlabelname) from	labelfile where labeldefinition = 'RevType2') reftype2_1,
	(select	max(userlabelname) from	labelfile where labeldefinition = 'RevType3') reftype3_1,
	(select	max(userlabelname) from	labelfile where labeldefinition = 'RevType4') reftype4_1,
	@v_ord_completion_ivhpyd_count ord_completion_ivhpyd_count,
	@v_refnum_count	refnum_count
FROM 	completion_orderheader
WHERE	ord_hdrnumber = @v_ord_hdrnumber

GO
GRANT EXECUTE ON  [dbo].[completion_orderheader_sp] TO [public]
GO
