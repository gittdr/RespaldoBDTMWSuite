SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Order_Child_Refresh_From_Master_sp]
		(@p_ord_hdrnumber_master int) 
AS

	DECLARE @ord_hdrnumber_child int,
		@mov_number_child int,
		@stp_sequence_parent int,
		@stp_sequence_child int,
		@recordcount_parent int,
		@stp_number_parent int,
		@stp_number_child int,
		@stp_event_parent varchar(6),
		@ErrorSave int, 
		@ErrorLocation varchar(30),
		@ErrorCount int,
		@err_message varchar(254),
		@nextrefsequence int,
		@nextrefrec int,
		--34195 JJF 8/21/06 Don't copy if reftype to be excluded from copying
		@CopyRefNumberExcludeRefType varchar(60),
		--34195 JJF 8/21/06 Don't copy if reftype to be excluded from copying
		--34525 JJF 9/15/06 - overwrite or replace reftype with another and blank out the value
		@CopyRefNumReplaceRefType	VARCHAR(60)
		--END 34525 JJF 9/15/06 - overwrite or replace reftype with another and blank out the value


	CREATE TABLE #master_referencenumber(
		ref_tablekey 	INTEGER 	NULL,
		ref_type 	VARCHAR(6) 	NULL,
		ref_number 	VARCHAR(20)	NULL,
		ref_typedesc 	VARCHAR(8) 	NULL,
		ref_sequence 	INTEGER 	NULL,
		ord_hdrnumber	INTEGER 	NULL,
		ref_table 	VARCHAR(18)	NULL,
		ref_sid 	CHAR(1) 	NULL,
		ref_pickup 	CHAR(1) 	NULL,
		ref_id		INTEGER IDENTITY(1,1) NOT NULL)

	SET @ErrorCount	= 0
	--If this is a master order being passed in...
	IF EXISTS(SELECT ord_hdrnumber 
			FROM orderheader
			WHERE ord_hdrnumber = @p_ord_hdrnumber_master AND ord_status = 'MST') BEGIN

		--Get list of child orders to process	
		SELECT	ohc.ord_number, ohc.ord_hdrnumber, ohc.mov_number, 0 as ErrorResult, space(30) as ErrorLocation
		INTO	#orderchildren
		FROM	orderheader ohm INNER JOIN orderheader ohc 
				ON ohm.ord_number = ohc.ord_fromorder
		WHERE	(ohc.ord_invoicestatus IN ('AVL', 'PND')) AND 
				--PTS 38336 JJF 20070712
				(ohc.ord_status <> 'CAN') AND
				--END PTS 38336 JJF 20070712
			(ohm.ord_hdrnumber = @p_ord_hdrnumber_master) 

		--If we have child orders...process them		
		IF EXISTS(SELECT ord_number 
				FROM #orderchildren) BEGIN
				
			--Prefetch master order info to copy
			SELECT 	mov_number,
				ord_company,
				ord_originpoint,
				ord_destpoint,
				ord_origincity,
				ord_destcity,
				ord_originstate,
				ord_deststate,
				ord_originregion1,
				ord_destregion1,
				ord_supplier,
				ord_billto,
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
				ord_description,
				cmd_code,
				ord_terms,
				cht_itemcode,
				ord_odmetermiles,
				ord_stopcount,
				ref_sid,
				ref_pickup,
				ord_cmdvalue,
				ord_accessorial_chrg,
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
				last_updateby,
				last_updatedate,
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
				ord_entryport,
				ord_exitport,
				ord_mileage_adj_pct,
				ord_commodities_weight,
				ord_intermodal,
				ord_order_source,
				ord_dimfactor,
				external_id,
				external_type,
				Ord_UnlockKey,
				ord_TrlConfiguration,
				ord_origin_zip,
				ord_dest_zip,
				ord_toll_cost_update_date,
				ord_toll_cost,
				ord_rate_mileagetable,
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
				ord_availabledate
			INTO	#master_orderheader
			FROM	orderheader 
			WHERE	(ord_hdrnumber = @p_ord_hdrnumber_master)

			SELECT	stp_number, 
				stp_sequence, 
				cmp_id, 
				stp_region1, 
				stp_region2, 
				stp_region3, 
				stp_city, 
				stp_state, 
				stp_type, 
				stp_paylegpt, 
				shp_hdrnumber, 
				stp_region4, 
				stp_lgh_sequence, 
				stp_mfh_sequence, 
				stp_event, 
				stp_mfh_position, 
				stp_lgh_position, 
				stp_mfh_status, 
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
				stp_screenmode, 
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
				stp_podname, 
				stp_custpickupdate, 
				stp_custdeliverydate, 
				stp_cmp_close, 
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
				stp_dispatched_status, 
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
				last_updatedatedepart
			INTO	#master_stops
			FROM	stops
			WHERE	(ord_hdrnumber = @p_ord_hdrnumber_master)
			
			SELECT	fgt.fgt_number, 
				stops.stp_sequence,
				fgt.fgt_sequence,
				fgt.cmd_code, 
				fgt.fgt_weight, 
				fgt.fgt_weightunit, 
				fgt.fgt_description, 
				fgt.stp_number, 
				fgt.fgt_count, 
				fgt.fgt_countunit, 
				fgt.fgt_volume, 
				fgt.fgt_volumeunit, 
				fgt.fgt_lowtemp, 
				fgt.fgt_hitemp, 
				fgt.fgt_length, 
				fgt.fgt_lengthunit, 
				fgt.fgt_height, 
				fgt.fgt_heightunit, 
				fgt.fgt_width, 
				fgt.fgt_widthunit, 
				fgt.fgt_reftype, 
				fgt.fgt_refnum, 
				fgt.fgt_quantity, 
				fgt.fgt_rate, 
				fgt.fgt_charge, 
				fgt.fgt_rateunit, 
				fgt.cht_itemcode, 
				fgt.cht_basisunit, 
				fgt.fgt_unit, 
				fgt.tare_weight, 
				fgt.tare_weightunit, 
				fgt.fgt_pallets_in, 
				fgt.fgt_pallets_out, 
				fgt.fgt_pallets_on_trailer, 
				fgt.fgt_carryins1, 
				fgt.fgt_carryins2, 
				fgt.fgt_stackable, 
				fgt.fgt_ratingquantity, 
				fgt.fgt_ratingunit, 
				fgt.fgt_quantity_type, 
				fgt.fgt_ordered_count, 
				fgt.fgt_ordered_weight, 
				fgt.tar_number, 
				fgt.tar_tariffnumber, 
				fgt.tar_tariffitem, 
				fgt.fgt_charge_type, 
				fgt.fgt_rate_type, 
				fgt.fgt_ordered_volume, 
				fgt.fgt_ordered_loadingmeters, 
				fgt.fgt_pallet_type, 
				fgt.fgt_loadingmeters, 
				fgt.fgt_loadingmetersunit, 
				fgt.fgt_additionl_description, 
				fgt.fgt_specific_flashpoint, 
				fgt.fgt_specific_flashpoint_unit, 
				fgt.cpr_density, 
				fgt.scm_subcode, 
				fgt.fgt_terms, 
				fgt.fgt_consignee, 
				fgt.fgt_shipper, 
				fgt.fgt_leg_origin, 
				fgt.fgt_leg_dest, 
				fgt.fgt_count2, 
				fgt.fgt_count2unit, 
				fgt.fgt_bolid, 
				fgt.fgt_bol_status, 
				fgt.fgt_osdreason, 
				fgt.fgt_osdquantity, 
				fgt.fgt_osdunit, 
				fgt.fgt_osdcomment
			INTO	#master_freightdetail	
			FROM	freightdetail fgt INNER JOIN
				stops ON fgt.stp_number = stops.stp_number
			WHERE	(stops.ord_hdrnumber = @p_ord_hdrnumber_master) 

			--34195 JJF 8/21/06 Don't copy if reftype to be excluded from copying
			SELECT @CopyRefNumberExcludeRefType = gi_string1
			FROM generalinfo
			WHERE (gi_name = 'CopyRefNumberExclude')
			--END 34195 JJF 8/21/06 Don't copy if reftype to be excluded from copying
			
			--34525 JJF 9/15/06 - overwrite or replace reftype with another and blank out the value
			SELECT 	@CopyRefNumReplaceRefType = gi_string1
			FROM generalinfo
			WHERE (gi_name = 'CopyRefNumReplaceRefType')
			--34525 JJF 9/15/06 - overwrite or replace reftype with another and blank out the value

			INSERT INTO #master_referencenumber(
				ref_tablekey,
				[ref_type],
				[ref_number],
				[ref_typedesc],
				[ref_table],
				[ref_sid],
				[ref_pickup])
			SELECT	ref_tablekey,
				[ref_type],
				[ref_number],
				[ref_typedesc],
				[ref_table],
				[ref_sid],
				[ref_pickup]
			FROM 	[referencenumber]
			WHERE 	ref_table = 'orderheader' 
				AND ref_tablekey = @p_ord_hdrnumber_master 
				--34195 JJF 8/21/06 Don't copy if reftype to be excluded from copying
				--AND ref_type <> ISNULL(@CopyRefNumberExcludeRefType, '')
				--34525 JJF 9/15/06 - don't copy the replaced reftype either
				  AND (ref_type <> ISNULL(@CopyRefNumberExcludeRefType, '')) AND ( ref_type <> ISNULL(@CopyRefNumReplaceRefType, ''))
				--34525 JJF 9/15/06 - don't copy the replaced reftype either
				--END 34195 JJF 8/21/06 Don't copy if reftype to be excluded from copying

			--Move thru the child order list
			SELECT @ord_hdrnumber_child = MIN(ord_hdrnumber)
			FROM #orderchildren
			
			WHILE (@ord_hdrnumber_child > 0) BEGIN
			
				SELECT @mov_number_child = mov_number
				FROM #orderchildren
				WHERE ord_hdrnumber = @ord_hdrnumber_child


				BEGIN TRAN child_update
				
				--copy master order info to this child
				UPDATE	orderheader
				SET	ord_company = m.ord_company,
					ord_originpoint = m.ord_originpoint, 
					ord_destpoint = m.ord_destpoint, 
					ord_origincity = m.ord_origincity, 
					ord_destcity = m.ord_destcity, 
					ord_originstate = m.ord_originstate, 
					ord_deststate = m.ord_deststate, 
					ord_originregion1 = m.ord_originregion1, 
					ord_destregion1 = m.ord_destregion1, 
					ord_supplier = m.ord_supplier, 
					ord_billto = m.ord_billto, 
					ord_revtype1 = m.ord_revtype1, 
					ord_revtype2 = m.ord_revtype2, 
					ord_revtype3 = m.ord_revtype3, 
					ord_revtype4 = m.ord_revtype4, 
					--JJF 7/19/2006 - should not be updated
					--ord_totalweight = m.ord_totalweight, 
					--END JJF 7/19/2006 - should not be updated
					ord_totalpieces = m.ord_totalpieces, 
					ord_totalmiles = m.ord_totalmiles, 
					ord_totalcharge = m.ord_totalcharge, 
					ord_currency = m.ord_currency, 
					ord_currencydate = m.ord_currencydate, 
					ord_totalvolume = m.ord_totalvolume, 
					--JJF 7/13/2006 Stamp the order header with the 1st reference number, since it may have been just modified
					--ord_refnum = m.ord_refnum,
					--end JJF 7/13/2006 Stamp the order header with the 1st reference number, since it may have been just modified
					ord_invoicewhole = m.ord_invoicewhole, 
					ord_remark = m.ord_remark, 
					ord_shipper = m.ord_shipper, 
					ord_consignee = m.ord_consignee, 
					ord_pu_at = m.ord_pu_at, 
					ord_dr_at = m.ord_dr_at, 
					ord_originregion2 = m.ord_originregion2,
					ord_originregion3 = m.ord_originregion3, 
					ord_originregion4 = m.ord_originregion4, 
					ord_destregion2 = m.ord_destregion2, 
					ord_destregion3 = m.ord_destregion3, 
					ord_destregion4 = m.ord_destregion4, 
					ord_priority = m.ord_priority, 
					tar_tarriffnumber = m.tar_tarriffnumber, 
					tar_number = m.tar_number, 
					tar_tariffitem = m.tar_tariffitem, 
					ord_contact = m.ord_contact, 
					ord_showshipper = m.ord_showshipper, 
					ord_showcons = m.ord_showcons, 
					ord_subcompany = m.ord_subcompany, 
					ord_lowtemp = m.ord_lowtemp, 
					ord_hitemp = m.ord_hitemp, 
					ord_quantity = m.ord_quantity, 
					ord_rate = m.ord_rate,
					ord_charge = m.ord_charge, 
					ord_rateunit = m.ord_rateunit, 
					ord_unit = m.ord_unit, 
					ord_length = m.ord_length, 
					ord_width = m.ord_width, 
					ord_height = m.ord_height, 
					ord_lengthunit = m.ord_lengthunit, 
					ord_widthunit = m.ord_widthunit, 
					ord_heightunit = m.ord_heightunit, 
					--JJF 7/13/2006 Stamp the order header with the 1st reference number, since it may have been just modified
					--ord_reftype = m.ord_reftype, 
					--end JJF 7/13/2006 Stamp the order header with the 1st reference number, since it may have been just modified
					ord_description = m.ord_description, 
					cmd_code = m.cmd_code, 
					ord_terms = m.ord_terms, 
					cht_itemcode = m.cht_itemcode, 
					ord_odmetermiles = m.ord_odmetermiles, 
					ord_stopcount = m.ord_stopcount, 
					ref_sid = m.ref_sid, 
					ref_pickup = m.ref_pickup, 
					ord_cmdvalue = m.ord_cmdvalue, 
					ord_accessorial_chrg = m.ord_accessorial_chrg, 
					ord_miscqty = m.ord_miscqty, 
					ord_tempunits = m.ord_tempunits, 
					ord_datetaken = m.ord_datetaken, 
					--JJF 7/19/2006 - should not be updated
					--ord_totalweightunits = m.ord_totalweightunits, 
					--END JJF 7/19/2006 - should not be updated
					ord_totalvolumeunits = m.ord_totalvolumeunits, 
					ord_totalcountunits = m.ord_totalcountunits, 
					ord_loadtime = m.ord_loadtime, 
					ord_unloadtime = m.ord_unloadtime, 
					ord_drivetime = m.ord_drivetime, 
					ord_rateby = m.ord_rateby, 
					ord_quantity_type = m.ord_quantity_type, 
					ord_charge_type = m.ord_charge_type, 
					ord_mintemp = m.ord_mintemp, 
					ord_maxtemp = m.ord_maxtemp, 
					ord_distributor = m.ord_distributor, 
					ord_cod_amount = m.ord_cod_amount, 
					appt_init = m.appt_init, 
					appt_contact = m.appt_contact, 
					ord_ratingquantity = m.ord_ratingquantity, 
					ord_ratingunit = m.ord_ratingunit, 
					ord_booked_revtype1 = m.ord_booked_revtype1, 
					ord_hideshipperaddr = m.ord_hideshipperaddr, 
					ord_hideconsignaddr = m.ord_hideconsignaddr, 
					--JJF 7/19/2006 - should not be updated
					--ord_tareweight = m.ord_tareweight, 
					--ord_grossweight = m.ord_grossweight, 
					--END JJF 7/19/2006 - should not be updated
					ord_mileagetable = m.ord_mileagetable, 
					ord_allinclusivecharge = m.ord_allinclusivecharge, 
					ord_extrainfo1 = m.ord_extrainfo1, 
					ord_extrainfo2 = m.ord_extrainfo2, 
					ord_extrainfo3 = m.ord_extrainfo3, 
					ord_extrainfo4 = m.ord_extrainfo4, 
					ord_extrainfo5 = m.ord_extrainfo5, 
					ord_extrainfo6 = m.ord_extrainfo6, 
					ord_extrainfo7 = m.ord_extrainfo7, 
					ord_extrainfo8 = m.ord_extrainfo8, 
					ord_extrainfo9 = m.ord_extrainfo9, 
					ord_extrainfo10 = m.ord_extrainfo10, 
					ord_extrainfo11 = m.ord_extrainfo11, 
					ord_extrainfo12 = m.ord_extrainfo12, 
					ord_extrainfo13 = m.ord_extrainfo13, 
					ord_extrainfo14 = m.ord_extrainfo14, 
					ord_extrainfo15 = m.ord_extrainfo15, 
					ord_rate_type = m.ord_rate_type, 
					ord_barcode = m.ord_barcode, 
					ord_broker = m.ord_broker, 
					ord_stlquantity = m.ord_stlquantity, 
					ord_stlunit = m.ord_stlunit, 
					ord_stlquantity_type = m.ord_stlquantity_type, 
					ord_fromschedule = m.ord_fromschedule, 
					ord_schedulebatch = m.ord_schedulebatch, 
					last_updateby = m.last_updateby, 
					last_updatedate = m.last_updatedate, 
					ord_revenue_pay_fix = m.ord_revenue_pay_fix, 
					ord_revenue_pay = m.ord_revenue_pay, 
					ord_reserved_number = m.ord_reserved_number, 
					ord_customs_document = m.ord_customs_document, 
					ord_noautosplit = m.ord_noautosplit, 
					ord_noautotransfer = m.ord_noautotransfer, 
					ord_totalloadingmeters = m.ord_totalloadingmeters, 
					ord_totalloadingmetersunit = m.ord_totalloadingmetersunit, 
					ord_charge_type_lh = m.ord_charge_type_lh, 
					ord_entryport = m.ord_entryport, 
					ord_exitport = m.ord_exitport, 
					ord_mileage_adj_pct = m.ord_mileage_adj_pct, 
					ord_commodities_weight = m.ord_commodities_weight, 
					ord_intermodal = m.ord_intermodal, 
					--JJF 7/19/2006 - should not be updated
					--ord_order_source = m.ord_order_source, 
					--END JJF 7/19/2006 - should not be updated
					ord_dimfactor = m.ord_dimfactor, 
					external_id = m.external_id, 
					external_type = m.external_type, 
					Ord_UnlockKey = m.Ord_UnlockKey, 
					ord_origin_zip = m.ord_origin_zip, 
					ord_dest_zip = m.ord_dest_zip, 
					ord_toll_cost_update_date = m.ord_toll_cost_update_date, 
					ord_toll_cost = m.ord_toll_cost, 
					ord_rate_mileagetable = m.ord_rate_mileagetable, 
					ord_raildest = m.ord_raildest, 
					ord_railpoolid = m.ord_railpoolid, 
					ord_route = m.ord_route, 
					ord_route_effc_date = m.ord_route_effc_date, 
					ord_route_exp_date = m.ord_route_exp_date, 
					ord_odmetermiles_mtid = m.ord_odmetermiles_mtid, 
					ord_edipurpose = m.ord_edipurpose, 
					ord_ediuseraction = m.ord_ediuseraction, 
					ord_edistate = m.ord_edistate, 
					ord_no_recalc_miles = m.ord_no_recalc_miles,
					ord_availabledate = m.ord_availabledate
				FROM	#master_orderheader m
				WHERE	ord_hdrnumber = @ord_hdrnumber_child
	
				SET @ErrorSave = @@ERROR
				IF @ErrorSave <> 0 BEGIN
					SET @ErrorLocation = 'Update OrderHeader'
					GOTO UPDATE_CHILD_ERROR
				END

				--Walk through stops in master and update corresponding stops in child
				SET @stp_sequence_parent = 1
				SET @stp_sequence_child = 1

				SELECT @recordcount_parent = count(*)
				FROM #master_stops
				
				WHILE (@stp_sequence_parent <= @recordcount_parent) BEGIN
					SELECT @stp_number_parent = stp_number,
						@stp_event_parent = stp_event
					FROM #master_stops
					WHERE stp_sequence = @stp_sequence_parent 

					SET @stp_number_child = NULL
					--Find the next child stop that matches the current parent stop's event
					SELECT 	@stp_number_child = stp_number
					FROM stops
					WHERE stops.ord_hdrnumber = @ord_hdrnumber_child AND
						stops.stp_sequence >= @stp_sequence_child AND
						stops.stp_event = @stp_event_parent
					
					IF @stp_number_child IS NOT NULL BEGIN
						SELECT 	@stp_sequence_child = stp_sequence
						FROM 	stops
						WHERE 	stp_number = @stp_number_child

						UPDATE	stops
						SET	cmd_code = stpm.cmd_code,
							stp_description = stpm.stp_description, 
							stp_weight = stpm.stp_weight, 
							stp_weightunit = stpm.stp_weightunit,
							cmp_id = stpm.cmp_id,
							cmp_name = stpm.cmp_name, 
							stp_city = stpm.stp_city, 
							stp_phonenumber = stpm.stp_phonenumber, 
							stp_zipcode = stpm.stp_zipcode, 
							stp_address = stpm.stp_address, 
							stp_contact = stpm.stp_contact, 
							stp_ord_mileage = stpm.stp_ord_mileage, 
							stp_lgh_mileage = stpm.stp_lgh_mileage, 
							stp_ord_mileage_mtid = stpm.stp_ord_mileage_mtid, 
							stp_lgh_mileage_mtid = stpm.stp_lgh_mileage_mtid,
							--above is updated by application during save in order entry
							stp_region1 = stpm.stp_region1, 
							stp_region2 = stpm.stp_region2, 
							stp_region3 = stpm.stp_region3, 
							stp_state = stpm.stp_state, 
							stp_type = stpm.stp_type, 
							stp_paylegpt = stpm.stp_paylegpt, 
							stp_region4 = stpm.stp_region4, 
							stp_mfh_mileage = stpm.stp_mfh_mileage, 
							stp_count = stpm.stp_count, 
							stp_countunit = stpm.stp_countunit, 
							stp_comment = stpm.stp_comment, 
							stp_reftype = stpm.stp_reftype, 
							stp_refnum = stpm.stp_refnum, 
							stp_volume = stpm.stp_volume, 
							stp_volumeunit = stpm.stp_volumeunit, 
							stp_type1 = stpm.stp_type1, 
							stp_pudelpref = stpm.stp_pudelpref, 
							stp_ooa_mileage = stpm.stp_ooa_mileage, 
							stp_OOA_stop = stpm.stp_OOA_stop, 
							stp_transfer_stp = stpm.stp_transfer_stp, 
							stp_phonenumber2 = stpm.stp_phonenumber2, 
							stp_address2 = stpm.stp_address2, 
							stp_podname = stpm.stp_podname, 
							stp_cmp_close = stpm.stp_cmp_close, 
							stp_transfer_type = stpm.stp_transfer_type, 
							stp_trip_mileage = stpm.stp_trip_mileage, 
							stp_stl_mileage_flag = stpm.stp_stl_mileage_flag, 
							stp_country = stpm.stp_country, 
							stp_loadingmeters = stpm.stp_loadingmeters, 
							stp_loadingmetersunit = stpm.stp_loadingmetersunit, 
							stp_cod_amount = stpm.stp_cod_amount, 
							stp_cod_currency = stpm.stp_cod_currency, 
							stp_extra_count = stpm.stp_extra_count, 
							stp_extra_weight = stpm.stp_extra_weight, 
							stp_alloweddet = stpm.stp_alloweddet, 
							stp_gfc_arr_radius = stpm.stp_gfc_arr_radius, 
							stp_gfc_arr_radiusunits = stpm.stp_gfc_arr_radiusunits, 
							stp_gfc_arr_timeout = stpm.stp_gfc_arr_timeout, 
							stp_count2 = stpm.stp_count2, 
							stp_countunit2 = stpm.stp_countunit2, 
							stp_ord_toll_cost = stpm.stp_ord_toll_cost, 
							stp_ooa_mileage_mtid = stpm.stp_ooa_mileage_mtid, 
							last_updateby = stpm.last_updateby, 
							last_updatedate = stpm.last_updatedate,
							skip_trigger = 1
						FROM	stops, #master_stops stpm 
						WHERE    stops.stp_number = @stp_number_child AND
							stpm.stp_number = @stp_number_parent
						
						SET @ErrorSave = @@ERROR
						IF @ErrorSave <> 0 BEGIN
							SET @ErrorLocation = 'Update stops'
							GOTO UPDATE_CHILD_ERROR
						END

						UPDATE	freightdetail
						SET	cmd_code = fgtm.cmd_code,
							fgt_weight = fgtm.fgt_weight, 
							fgt_weightunit = fgtm.fgt_weightunit, 
							fgt_description = fgtm.fgt_description, 
							fgt_quantity = fgtm.fgt_quantity, 
							fgt_unit = fgtm.fgt_unit, 
							fgt_ordered_weight = fgtm.fgt_ordered_weight,
							--above is updated by application during save in order entry
							fgt_count = fgtm.fgt_count, 
							fgt_countunit = fgtm.fgt_countunit, 
							fgt_volume = fgtm.fgt_volume, 
							fgt_volumeunit = fgtm.fgt_volumeunit, 
							fgt_lowtemp = fgtm.fgt_lowtemp, 
							fgt_hitemp = fgtm.fgt_hitemp, 
							fgt_sequence = fgtm.fgt_sequence, 
							fgt_length = fgtm.fgt_length, 
							fgt_lengthunit = fgtm.fgt_lengthunit, 
							fgt_height = fgtm.fgt_height, 
							fgt_heightunit = fgtm.fgt_heightunit, 
							fgt_width = fgtm.fgt_width, 
							fgt_widthunit = fgtm.fgt_widthunit, 
							fgt_reftype = fgtm.fgt_reftype, 
							fgt_refnum = fgtm.fgt_refnum, 
							fgt_rate = fgtm.fgt_rate, 
							fgt_charge = fgtm.fgt_charge, 
							fgt_rateunit = fgtm.fgt_rateunit, 
							cht_itemcode = fgtm.cht_itemcode, 
							cht_basisunit = fgtm.cht_basisunit, 
							tare_weight = fgtm.tare_weight, 
							tare_weightunit = fgtm.tare_weightunit, 
							fgt_carryins1 = fgtm.fgt_carryins1, 
							fgt_carryins2 = fgtm.fgt_carryins2, 
							fgt_stackable = fgtm.fgt_stackable, 
							fgt_ratingquantity = fgtm.fgt_ratingquantity, 
							fgt_ratingunit = fgtm.fgt_ratingunit, 
							fgt_ordered_count = fgtm.fgt_ordered_count, 
							tar_number = fgtm.tar_number, 
							tar_tariffnumber = fgtm.tar_tariffnumber, 
							tar_tariffitem = fgtm.tar_tariffitem, 
							fgt_charge_type = fgtm.fgt_charge_type, 
							fgt_rate_type = fgtm.fgt_rate_type, 
							fgt_ordered_volume = fgtm.fgt_ordered_volume, 
							fgt_ordered_loadingmeters = fgtm.fgt_ordered_loadingmeters, 
							fgt_pallet_type = fgtm.fgt_pallet_type, 
							fgt_loadingmeters = fgtm.fgt_loadingmeters, 
							fgt_loadingmetersunit = fgtm.fgt_loadingmetersunit, 
							fgt_additionl_description = fgtm.fgt_additionl_description, 
							fgt_specific_flashpoint = fgtm.fgt_specific_flashpoint, 
							fgt_specific_flashpoint_unit = fgtm.fgt_specific_flashpoint_unit, 
							cpr_density = fgtm.cpr_density, 
							scm_subcode = fgtm.scm_subcode, 
							fgt_terms = fgtm.fgt_terms, 
							fgt_consignee = fgtm.fgt_consignee, 
							fgt_shipper = fgtm.fgt_shipper, 
							fgt_leg_origin = fgtm.fgt_leg_origin, 
							fgt_leg_dest = fgtm.fgt_leg_dest, 
							fgt_count2 = fgtm.fgt_count2, 
							fgt_count2unit = fgtm.fgt_count2unit, 
							fgt_bolid = fgtm.fgt_bolid, 
							fgt_bol_status = fgtm.fgt_bol_status,
							skip_trigger = 1
						FROM	freightdetail INNER JOIN
							stops ON freightdetail.stp_number = stops.stp_number INNER JOIN
							#master_freightdetail fgtm ON freightdetail.fgt_sequence = fgtm.fgt_sequence 
						WHERE    stops.stp_number = @stp_number_child
							and fgtm.stp_sequence = @stp_sequence_parent
		
						SET @ErrorSave = @@ERROR
						IF @ErrorSave <> 0 BEGIN
							SET @ErrorLocation = 'Update freightdetail'
							GOTO UPDATE_CHILD_ERROR
						END
					END

					SET @stp_sequence_parent = @stp_sequence_parent + 1
				END 

				--Update reference numbers where the type exists 
				UPDATE referencenumber  SET
					[ref_number] = mr.ref_number,
					[ref_typedesc] = mr.ref_typedesc,
					[ref_sid] = mr.ref_sid,
					[ref_pickup] = mr.ref_pickup
				FROM 	#master_referencenumber mr
				WHERE   referencenumber.ref_tablekey = @ord_hdrnumber_child and
					referencenumber.ref_table = mr.ref_table and 
					referencenumber.ref_type = mr.ref_type

				--Add new ref numbers
				SELECT @nextrefsequence = (SELECT isnull(max(refinner.ref_sequence), 0) + 1 
						FROM referencenumber refinner 
						WHERE refinner.ref_tablekey = @ord_hdrnumber_child and
							refinner.ref_table = 'orderheader')

				
				SELECT 	@nextrefrec = min(mr.ref_id)
				FROM	#master_referencenumber mr

				WHILE @nextrefrec IS NOT NULL BEGIN
				
					IF NOT EXISTS(SELECT * 
						FROM referencenumber refinner INNER JOIN #master_referencenumber mr 
							ON refinner.ref_type = mr.ref_type AND 
								refinner.ref_table = mr.ref_table 	
						WHERE refinner.ord_hdrnumber = @ord_hdrnumber_child AND 
							 mr.ref_id = @nextrefrec) BEGIN

				
						INSERT INTO referencenumber(
							ref_tablekey,
							ref_type,
							ref_number,
							ref_typedesc,
							ref_sequence,
							ord_hdrnumber, 
							ref_table,
							ref_sid,
							ref_pickup)
						SELECT @ord_hdrnumber_child,
							ref_type,
							ref_number,
							ref_typedesc,
							@nextrefsequence,
							@ord_hdrnumber_child, 
							ref_table,
							ref_sid,
							ref_pickup
						FROM #master_referencenumber
						WHERE ref_id = @nextrefrec

						SELECT @nextrefsequence = @nextrefsequence + 1
			  	  	END


					SELECT 	@nextrefrec = min(mr.ref_id)
					FROM	#master_referencenumber mr
					WHERE 	mr.ref_id > @nextrefrec

				END

				--JJF 7/13/2006 Stamp the order header with the 1st reference number, since it may have been just modified
				UPDATE	orderheader
				SET	ord_reftype = r.ref_type,
					ord_refnum = r.ref_number
				FROM	referencenumber r
				WHERE	orderheader.ord_hdrnumber = @ord_hdrnumber_child and
					r.ref_tablekey = @ord_hdrnumber_child and
					r.ref_table = 'orderheader' and 
					ref_sequence = 1
				--END JJF 7/13/2006 Stamp the order header with the 1st reference number, since it may have been just modified
				
				EXEC update_move_light @mov_number_child
				
				SET @ErrorSave = @@ERROR
				IF @ErrorSave <> 0 BEGIN
					SET @ErrorLocation = 'update_move_light'
					GOTO UPDATE_CHILD_ERROR
				END

				COMMIT TRAN child_update
				
				--set @err_message = 'Cascade success from master order ord_hdrnumber: ' + cast(@p_ord_hdrnumber_master as varchar)
				--set @err_message = @err_message + ' to order ord_hdrnumber: ' + cast(@ord_hdrnumber_child as varchar)
				--insert tts_errorlog (err_batch, err_user_id, err_message, err_date, err_number, err_title, err_item_number)
				--select 0, suser_sname(), @err_message, getdate(), @ErrorSave, 'Order_Child_Refresh_From_Master_sp success', 0

				GOTO CONTINUE_NEXT_CHILD
				
UPDATE_CHILD_ERROR:
				ROLLBACK TRAN
		
				set @err_message = 'An error occured while cascading changes from master order ord_hdrnumber: ' + cast(@p_ord_hdrnumber_master as varchar)
				set @err_message = @err_message + ' to order ord_hdrnumber: ' + cast(@ord_hdrnumber_child as varchar)
				set @err_message = @err_message + '.  err_number is the SQL error number.  Error Location: ' + @ErrorLocation
				insert tts_errorlog (err_batch, err_user_id, err_message, err_date, err_number, err_title, err_item_number)
				select 0, suser_sname(), @err_message, getdate(), @ErrorSave, 'Order_Child_Refresh_From_Master_sp error', 0
		
				UPDATE	#orderchildren
				SET	ErrorResult = @ErrorSave,
					ErrorLocation = @ErrorLocation
				WHERE	ord_hdrnumber = @ord_hdrnumber_child
				
CONTINUE_NEXT_CHILD:
				SELECT @ord_hdrnumber_child = MIN(ord_hdrnumber) 
				FROM #orderchildren
				WHERE ord_hdrnumber > @ord_hdrnumber_child
				
			END

		END
		--Return resultset showing what orders were affected
		SELECT	ord_number, mov_number, ErrorResult, ErrorLocation
		FROM	#orderchildren
		
		SELECT @ErrorCount = count(*)
		FROM #orderchildren
		WHERE ErrorResult <> 0
		
	END 
	
	RETURN @ErrorCount
GO
GRANT EXECUTE ON  [dbo].[Order_Child_Refresh_From_Master_sp] TO [public]
GO
