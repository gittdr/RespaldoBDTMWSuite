SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROC [dbo].[create_tmw_order_from_completion_sp] (@p_ord_hdrnumber int)

AS
/**
 * 
 * NAME:
 * create_tmw_order_from_completion_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * 
 * RETURNS: 1 If All Deletes/Inserts Succeed
 *			A negative number starting with -1 if any errors are encountered JD 44372
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS: @p_ord_hdrnumber		int	Order Header Number To Create
 *
 * REVISION HISTORY:
 * 8/2/2006.01 ? PTS33397 - Dan Hudec ? Created Procedure
 * 2/15/2007.01 - JG - reduce reads and cpu time in a few places, also with index changes.
 * 2/28/2007.01 - FM - added ISNULL to ord_terms to prevent EDI 210 processing from abending
 * 8/14/07 - DPETE 38953 accessorials with sequence 1 is messing up rating
 * 4/27/2008.01 - vjh 42199 prevent the loss of ord_batchratestatus on delete/insert
 * 09/05/2008	44372 JD added transaction and error handling. Did limited sql cleanup.
 * 12/02/2008 44766 pmill set arrival and departure dates
 * 12/02/2008 44461 populate hubmiles and odometer readings from order completion
 * 02/03/2009 pmill additional changes to transaction logic to prevent lost data
 * 11/16/09 PTS 48803 DPETE make sure pickup stops have all the freight the delivery stops have  
 * 03/31/2011 PTS 56334 SPN now on we are using referencenumber table instead of completion_referencenumber
 * 01/11/2011 PTS 60791 recalculate the total miles and update it in completion_orderheader and orderheader
 * 03/07/2012 PTS 58560 NQIAO - restore frieight reference number based on mov_number instead of ord_hdrnumber
 **/

DECLARE	@v_cur_stp_number 			int,
		@v_cur_mfh_sequence 		int,
		@v_max_mfh_sequence			int,
		@v_stp_completion_driver1	varchar(8),
		@v_stp_completion_driver2	varchar(8),
		@v_stp_completion_tractor	varchar(8),
		@v_stp_completion_trailer	varchar(8),
		@v_temp_driver1				varchar(8),
		@v_temp_driver2				varchar(8),
		@v_temp_tractor				varchar(8),
		@v_temp_trailer				varchar(8),
		@v_temp_ord_status			varchar(6),
		@v_ord_carrier				varchar(8),
		@v_mov_number				int,
		@v_stop_count				int,
		@v_ord_shiftdate			datetime,
		@v_ord_shiftid				int,
		@v_total_volume				float,
		@v_temp_cmd_code			varchar(8),
		@v_return_code				int,
		@v_ord_batcheligible		char(1),
		@v_ord_batchstatus			char(1),
		@v_ord_billto				varchar(8),
		@v_origin_city				int,
		@v_lgh_number				int,
		@v_temp_odometer_miles			int,    --44461 pmill
		@v_temp_odometer_start			int,    --44461 pmill
		@v_temp_odometer_end			int     --44461 pmill


--CGK PTS 57732 Create table to Backup the Freight Detail referencenumbers
CREATE TABLE #referencenumberfreightdetail (
	[ref_tablekey] [int] NULL,
	[ref_type] [varchar](6) NULL,
	[ref_number] [varchar](30) NULL,
	[ref_typedesc] [varchar](8) NULL,
	[ref_sequence] [int] NULL,
	[ord_hdrnumber] [int] NULL,
	[ref_table] [varchar](18) NULL,
	[ref_sid] [char](1) NULL,
	[ref_pickup] [char](1) NULL,
	[last_updateby] [varchar](256) NULL,
	[last_updatedate] [datetime] NULL)


--FMM 3/21/07 moved BEGIN TRAN

--FMM 3/21/07 better performing query
--If Exists (select * from orderheader
--	   where ord_hdrnumber = @p_ord_hdrnumber)

SELECT	@v_ord_batcheligible = ord_batchrateeligibility, @v_ord_batchstatus = ord_batchratestatus,@v_mov_number = mov_number		--vjh 42199
FROM	orderheader
WHERE	ord_hdrnumber = @p_ord_hdrnumber -- JD 44372 get all the values from the orderheader

--JD 45210 check for null leg numbers
If exists (select * from completion_stops where mov_number = @v_mov_number and lgh_number is null)
begin
	select @v_lgh_number = min(lgh_number) from legheader where mov_number = @v_mov_number
	update completion_stops set lgh_number = @v_lgh_number where mov_number = @v_mov_number and lgh_number is null
end
-- JD end check for null leg numbers


-- NQIAO 05/20/11 PTS 57037 <start> - ord_completion_odometer_start and ord_completion_odometer_end fields in table completion_orderheader
-- should reflect the first and last stops' stp_completion_odometer values in the completion_stops table.
IF @v_mov_number IS NULL OR @v_mov_number = '' 
BEGIN
	SELECT	@v_mov_number = mov_number
	FROM	completion_orderheader
	WHERE	ord_hdrnumber = @p_ord_hdrnumber
END

IF @v_mov_number IS NOT NULL AND @v_mov_number <> ''
BEGIN
SELECT	@v_temp_odometer_start = stp_completion_odometer
FROM	completion_stops
WHERE	mov_number = @v_mov_number
AND		stp_mfh_sequence = (select min(stp_mfh_sequence) from completion_stops where mov_number = @v_mov_number)

SELECT	@v_temp_odometer_end = stp_completion_odometer
FROM	completion_stops
WHERE	mov_number = @v_mov_number
AND		stp_mfh_sequence = (select max(stp_mfh_sequence) from completion_stops where mov_number = @v_mov_number)

UPDATE	completion_orderheader
SET		ord_completion_odometer_start = @v_temp_odometer_start,
		ord_completion_odometer_end = @v_temp_odometer_end,
		ord_totalmiles = @v_temp_odometer_end - @v_temp_odometer_start		-- NQIAO 01/11/2012 PTS 60791
WHERE	ord_hdrnumber = @p_ord_hdrnumber
END
-- NQIAO 05/20/11 PTS 57037 <end>	

BEGIN TRAN  --PMILL
IF exists (SELECT * FROM orderheader WHERE ord_hdrnumber = @p_ord_hdrnumber) 
 BEGIN

--	BEGIN TRAN  --FMM 3/21/07  --PMILL
		IF exists (SELECT * FROM invoiceheader WHERE ord_hdrnumber = @p_ord_hdrnumber) 
		 BEGIN
			SELECT	@v_temp_driver1 = ord_driver1,
					@v_temp_driver2 = ord_driver2,
					@v_temp_tractor = ord_tractor,
					@v_temp_trailer = ord_trailer,
					@v_temp_ord_status = ord_status,
					--44461 pmill add odometer start and end
					@v_temp_odometer_start = ord_completion_odometer_start,
					@v_temp_odometer_end = ord_completion_odometer_end	
			FROM	completion_orderheader
			WHERE	ord_hdrnumber = @p_ord_hdrnumber
	
			UPDATE	orderheader
			SET		ord_driver1	= @v_temp_driver1,
					ord_driver2 = @v_temp_driver2,
					ord_tractor = @v_temp_tractor,
					ord_trailer = @v_temp_trailer,
					--44461 pmill add odometer start and end					
					ord_odometer_start = @v_temp_odometer_start,
					ord_odometer_end = @v_temp_odometer_end,
					ord_totalmiles = @v_temp_odometer_end - @v_temp_odometer_start		-- NQIAO 01/11/2012 PTS 60791
			WHERE	ord_hdrnumber = @p_ord_hdrnumber

			IF @v_temp_ord_status = 'CMP'
			 BEGIN
				UPDATE	orderheader
				SET		ord_status	= @v_temp_ord_status
				WHERE	ord_hdrnumber = @p_ord_hdrnumber
			 END

			SELECT	@v_ord_carrier = ord_carrier
			FROM	completion_orderheader
			WHERE	ord_hdrnumber = @p_ord_hdrnumber

			SELECT 	@v_cur_mfh_sequence = 1

			SELECT	@v_cur_stp_number = stp_number
			FROM	completion_stops
			WHERE	mov_number = @v_mov_number
			AND	stp_mfh_sequence = @v_cur_mfh_sequence

			SELECT	@v_max_mfh_sequence = max(stp_mfh_sequence)
			FROM	completion_stops
			where	mov_number = @v_mov_number

			--44461 pmill get odometer miles
			SELECT @v_temp_odometer_miles = stp_completion_odometer
			FROM completion_stops
			WHERE stp_number = @v_cur_stp_number

			WHILE @v_cur_mfh_sequence <= @v_max_mfh_sequence
			 BEGIN
				UPDATE	event
				SET	evt_driver1 = @v_temp_driver1, 
					evt_driver2 = @v_temp_driver2, 
					evt_tractor = @v_temp_tractor, 
					evt_trailer1 = @v_temp_trailer, 
					evt_carrier = IsNull(@v_ord_carrier, 'UNKNOWN'),
					evt_hubmiles = @v_temp_odometer_miles		--44461 pmill write odometer miles back
				WHERE	stp_number = @v_cur_stp_number

				SELECT 	@v_cur_mfh_sequence = min(stp_mfh_sequence) 
  				FROM 	completion_stops
				WHERE 	stp_mfh_sequence > @v_cur_mfh_sequence
				--jg begin
						AND mov_number = @v_mov_number
				--jg end
	
				SELECT	@v_cur_stp_number = stp_number
				FROM	completion_stops
				WHERE	mov_number = @v_mov_number
				AND	stp_mfh_sequence = @v_cur_mfh_sequence
			 END

			UPDATE	legheader
			SET	lgh_driver1 = @v_temp_driver1, 
				lgh_driver2 = @v_temp_driver2, 
				lgh_tractor = @v_temp_tractor, 
				lgh_primary_trailer = @v_temp_trailer, 
				lgh_carrier = @v_ord_carrier
			WHERE	mov_number = @v_mov_number

			--BEGIN PTS 56334 SPN
			--DELETE FROM referencenumber
			--WHERE ord_hdrnumber = @p_ord_hdrnumber
			--END PTS 56334 SPN

--			COMMIT TRAN	--PMILL
--	
--			BEGIN TRAN	--PMILL
			--Insert Referencenumbers
			--BEGIN PTS 56334 SPN
			--INSERT INTO referencenumber(
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
			--FROM 	completion_referencenumber
			--WHERE	ord_hdrnumber = @p_ord_hdrnumber
			--END PTS 56334 SPN

			SET @v_return_code = @@error

			If @v_return_code <> 0
			 BEGIN
				Rollback Tran
				Return - 1
			 END
			ELSE
			 BEGIN
				Commit Tran
			 END

			--Call Update Move
			exec completion_update_move @v_mov_number

			SELECT	@v_ord_shiftdate = ord_completion_shift_date,
					@v_ord_shiftid = ord_completion_shift_id
			FROM	completion_orderheader
			WHERE	ord_hdrnumber = @p_ord_hdrnumber

			UPDATE	stops
			SET		cmd_code = 'UNKNOWN'
			WHERE	ord_hdrnumber = @p_ord_hdrnumber
			and		stp_type = 'DRP'
			and		cmd_code IS NULL

			--jg begin
			IF @v_ord_shiftdate is not null or @v_ord_shiftid is not null
			--jg end
			UPDATE	legheader
			SET		lgh_shiftdate = @v_ord_shiftdate,
					lgh_shiftnumber = @v_ord_shiftid
			--WHERE	ord_hdrnumber = @p_ord_hdrnumber
			WHERE	mov_number = @v_mov_number -- JD 36951

			Return 1
		 END
		ELSE
		 BEGIN
		  	-- NQIAO PTS 58560 <START> - relocated to here to user orderheader data
			INSERT INTO #referencenumberfreightdetail(
				ref_tablekey, 
				ref_type, 
				ref_number, 
				ref_typedesc, 
				ref_sequence, 
				ord_hdrnumber, 
				ref_table, 
				ref_sid, 
				ref_pickup, 
				last_updateby, 
				last_updatedate)
			SELECT 	ref_tablekey, 
				ref_type, 
				ref_number, 
				ref_typedesc, 
				ref_sequence, 
				ord_hdrnumber, 
				ref_table, 
				ref_sid, 
				ref_pickup, 
				last_updateby, 
				last_updatedate
			FROM 	referencenumber
			--WHERE	ord_hdrnumber = @p_ord_hdrnumber
			WHERE	ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_hdrnumber > 0 and mov_number = @v_mov_number)	-- 58560 NQIAO use mov_number
			AND ref_table = 'freightdetail' 
			-- NQIAO PTS 58560 <END>
		 
			DELETE FROM orderheader
			WHERE ord_hdrnumber = @p_ord_hdrnumber

			if @@error <> 0 
			begin
				rollback tran
				return -2
			end

			-- NQIAO PTS 58560 - moved above before 'DELETE FROM orderheader'
			/*--CGK PTS 57732 Backup the Freight Detail reference numbers because they get deleted by the freightdetail trigger	
			INSERT INTO #referencenumberfreightdetail(
				ref_tablekey, 
				ref_type, 
				ref_number, 
				ref_typedesc, 
				ref_sequence, 
				ord_hdrnumber, 
				ref_table, 
				ref_sid, 
				ref_pickup, 
				last_updateby, 
				last_updatedate)
			SELECT 	ref_tablekey, 
				ref_type, 
				ref_number, 
				ref_typedesc, 
				ref_sequence, 
				ord_hdrnumber, 
				ref_table, 
				ref_sid, 
				ref_pickup, 
				last_updateby, 
				last_updatedate
			FROM 	referencenumber
			WHERE	ord_hdrnumber = @p_ord_hdrnumber
			AND ref_table = 'freightdetail' 
			--CGK End PTS 57732 
			*/
			
			DELETE FROM freightdetail
			WHERE stp_number in (select stp_number from stops
						 where ord_hdrnumber = @p_ord_hdrnumber
						   and ord_hdrnumber > 0)

			if @@error <> 0 
			begin
				rollback tran
				return -3
			end
			
			DELETE FROM stops
			WHERE mov_number = @v_mov_number

			if @@error <> 0 
			begin
				rollback tran
				return -4
			end


			--BEGIN PTS 56334 SPN
			--DELETE FROM referencenumber
			--WHERE ord_hdrnumber = @p_ord_hdrnumber
			--END PTS 56334 SPN

			if @@error <> 0 
			begin
				rollback tran
				return -5
			end

--			COMMIT TRAN  --FMM 3/21/07	--PMILL
		 END
 END

--FMM 3/21/07 better performing query
--If Not Exists (select * from invoiceheader where ord_hdrnumber = @p_ord_hdrnumber)
IF (SELECT COUNT(*) FROM invoiceheader WHERE ord_hdrnumber = @p_ord_hdrnumber) = 0
 BEGIN
	DELETE FROM invoicedetail
	WHERE ord_hdrnumber = @p_ord_hdrnumber
 END

SELECT	@v_stop_count = ord_completion_pickup_count + ord_completion_drop_count
FROM	completion_orderheader
WHERE	ord_hdrnumber = @p_ord_hdrnumber

SELECT	@v_total_volume = sum(fgt_volume)
FROM	completion_freightdetail
--jg begin
--WHERE	Upper(Left(fgt_consignee, 3)) <> 'UNK'
WHERE fgt_consignee NOT IN ('UNK', 'UNKNOWN')
--jg end
-- 48803 add stp_type to where clause
AND		stp_number in (select stp_number from completion_stops
						where ord_hdrnumber = @p_ord_hdrnumber
                        and ord_hdrnumber > 0  
                        and stp_type = 'DRP')


--FMM 3/20/2007 removed per Eric Blinn
/*
IF @v_ord_batcheligible IS NULL
	SELECT @v_ord_batcheligible = 'N'
*/

--BEGIN TRAN  --FMM 3/21/2007	--PMILL

--Insert Orderheader
INSERT INTO orderheader (ord_company, 
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
	ord_batchrateeligibility,
	ord_batchratestatus,
	ord_odometer_start,		--44461
	ord_odometer_end)    		--44461
SELECT	'UNKNOWN',  	--ord_company
	ord_number, 
	'UNKNOWN', 			--ord_customer
	ord_bookdate, 
	ord_bookedby, 
	ord_status, 
	ord_shipper,  		--ord_originpoint
	ord_consignee,    	--ord_destpoint
	ord_invoicestatus, 
	@v_origin_city,		--ord_origincity, 
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
	@v_total_volume,	--ord_totalvolume, 
	ord_hdrnumber, 
	ord_refnum, 
	ord_invoicewhole, 
	ord_remark, 
	ord_shipper, 
	ord_consignee, 
	'SHP', 
	'CNS', 
	ord_originregion2, 
	ord_originregion3, 
	ord_originregion4, 
	ord_destregion2, 
	ord_destregion3, 
	ord_destregion4, 
	mfh_hdrnumber, 
	'UNK', 				--ord_priority
	mov_number, 
	tar_tarriffnumber, 
	tar_number, 
	tar_tariffitem, 
	ord_contact, 
	'UNKNOWN', 
	'UNKNOWN', 
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
	'UNKNOWN',			--cmd_code
	'UNKNOWN',			--ord_description
	ISNULL(ord_terms,'UNK'), 
	cht_itemcode, 
	ord_startdate,  		--ord_origin_earliestdate
	ord_startdate, 	 		--ord_origin_latestdate
	ord_completion_bill_miles, 	--ord_odmetermiles (could be pay miles also)
	@v_stop_count, 			--ord_stopcount
	ord_completiondate, 		--ord_dest_earliestdate
	ord_completiondate, 		--ord_dest_latestdate
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
	'UNKNOWN',			--ord_booked_revtype1
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
	0,							--ord_noautosplit
	0,							--ord_noautotransfer
	ord_totalloadingmeters, 
	ord_totalloadingmetersunit, 
	ord_charge_type_lh, 
	ord_complete_stamp, 
	last_updateby, 
	last_updatedate, 
	'UNKNOWN',					--ord_entryport
	'UNKNOWN',					--ord_exitport
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
	@v_ord_batcheligible,
	@v_ord_batchstatus,			-- vjh 42199
	ord_completion_odometer_start,		--44461
	ord_completion_odometer_end		--44461
FROM 	completion_orderheader
WHERE	ord_hdrnumber = @p_ord_hdrnumber

SET @v_return_code = @@error

If @v_return_code <> 0
 BEGIN
	Rollback Tran
	Return - 6
 END

SELECT	@v_origin_city = cmp_city
FROM	orderheader, company
WHERE	orderheader.ord_originpoint = company.cmp_id
  AND	orderheader.ord_hdrnumber = @p_ord_hdrnumber

UPDATE	orderheader
SET		ord_origincity = @v_origin_city
WHERE	orderheader.ord_hdrnumber = @p_ord_hdrnumber

UPDATE	completion_orderheader
SET		ord_origincity = @v_origin_city
WHERE	completion_orderheader.ord_hdrnumber = @p_ord_hdrnumber
--Insert Orderheader

--Insert Stops
--SELECT 	@v_cur_mfh_sequence = 1 --JD44372 Always use the min sequence.
--JD 


-- JD changed logic to loop through all the sequences
SELECT 	@v_mov_number = mov_number
FROM	completion_orderheader
WHERE	ord_hdrnumber = @p_ord_hdrnumber

--JD 45210 check for null leg numbers
If exists (select * from completion_stops where mov_number = @v_mov_number and lgh_number is null)
begin
	select @v_lgh_number = min(lgh_number) from legheader where mov_number = @v_mov_number
	update completion_stops set lgh_number = @v_lgh_number where mov_number = @v_mov_number and lgh_number is null
end
-- JD end check for null leg numbers


Select @v_cur_mfh_sequence = 0
WHILE 1= 1
BEGIN
	SELECT	@v_cur_mfh_sequence = min(stp_mfh_sequence)
	FROM	completion_stops
	where	mov_number = @v_mov_number and
			stp_mfh_sequence > @v_cur_mfh_sequence
	
	IF @v_cur_mfh_sequence is null
		BREAK


	SELECT	@v_cur_stp_number = stp_number
	FROM	completion_stops
	WHERE	mov_number = @v_mov_number
	AND	stp_mfh_sequence = @v_cur_mfh_sequence
	

	SELECT	@v_temp_cmd_code = min(cmd_code) 
	FROM	completion_freightdetail
	WHERE	stp_number = @v_cur_stp_number
	  and	cmd_code not like 'UNK%'

	INSERT INTO stops (ord_hdrnumber, 
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
		stp_unload_paytype)
	SELECT	ord_hdrnumber, 
		stp_number, 
		cmp_id, 
		stp_region1, 
		stp_region2, 
		stp_region3, 
		stp_city, 
		stp_state, 
		stp_schdtearliest, 
		stp_origschdt, 
		stp_arrivaldate,	--stp_schdtearliest  44766 put arrivaldate back
		stp_departuredate,	--stp_schdtlatest    44766 put departuredate back
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
		IsNull(@v_temp_cmd_code, 'UNKNOWN')  cmd_code, 
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
		'DNE', --stp_departure_status, 
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
		0, 
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
		stp_unload_paytype
	FROM 	completion_stops
	WHERE	stp_number = @v_cur_stp_number
	ORDER BY stp_mfh_sequence

	SET @v_return_code = @@error

	If @v_return_code <> 0
	 BEGIN
		Rollback Tran
		Return - 7
	 END
	
	SELECT 	@v_stp_completion_driver1 = stp_completion_driver1, 
		@v_stp_completion_driver2 = stp_completion_driver2,
		@v_temp_odometer_miles = stp_completion_odometer  --44461 pmill
	FROM	completion_stops
	WHERE	stp_number = @v_cur_stp_number

	SELECT	@v_stp_completion_tractor = ord_tractor,
		@v_stp_completion_trailer = ord_trailer
	FROM	orderheader
	WHERE	ord_hdrnumber = @p_ord_hdrnumber

	SELECT	@v_ord_carrier = ord_carrier
	FROM	completion_orderheader
	WHERE	ord_hdrnumber = @p_ord_hdrnumber

	UPDATE	event
	SET	evt_driver1 = @v_stp_completion_driver1, 
		evt_driver2 = @v_stp_completion_driver2, 
		evt_tractor = @v_stp_completion_tractor, 
		evt_trailer1 = @v_stp_completion_trailer, 
		evt_carrier = IsNull(@v_ord_carrier, 'UNKNOWN'),
		evt_hubmiles = @v_temp_odometer_miles    --44461 pmill
	WHERE	stp_number = @v_cur_stp_number

	UPDATE	completion_freightdetail
	SET		stp_number = stp_number * -1
	WHERE	completion_freightdetail.stp_number = -@v_cur_stp_number

	--Insert Freightdetails
	INSERT INTO freightdetail(
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
		fgt_supplier,
		fgt_accountof,
		fgt_volume2,
		fgt_volume2unit,
		fgt_display_sequence,
		fgt_parentcmd_fgt_number)

	SELECT 	completion_freightdetail.fgt_number, 
		completion_freightdetail.cmd_code, 
		completion_freightdetail.fgt_weight, 
		completion_freightdetail.fgt_weightunit,
		completion_freightdetail.fgt_description, 
		completion_freightdetail.stp_number, 
		completion_freightdetail.fgt_count, 
		completion_freightdetail.fgt_countunit, 
		completion_freightdetail.fgt_completion_billedamt, 
		completion_freightdetail.fgt_volumeunit, 
		completion_freightdetail.fgt_lowtemp, 
		completion_freightdetail.fgt_hitemp, 
		completion_freightdetail.fgt_sequence, 
		completion_freightdetail.fgt_length, 
		completion_freightdetail.fgt_lengthunit, 
		completion_freightdetail.fgt_height, 
		completion_freightdetail.fgt_heightunit, 
		completion_freightdetail.fgt_width, 
		completion_freightdetail.fgt_widthunit,  
		completion_freightdetail.fgt_reftype, 
		completion_freightdetail.fgt_refnum, 
		completion_freightdetail.fgt_completion_billedamt,  --completion_freightdetail.fgt_quantity
		completion_freightdetail.fgt_rate, 
		completion_freightdetail.fgt_charge, 
		completion_freightdetail.fgt_rateunit, 
		completion_freightdetail.cht_itemcode,  
		IsNull(completion_freightdetail.cht_basisunit, 'UNK'), 
		completion_freightdetail.fgt_unit, 
		completion_freightdetail.skip_trigger, 
		completion_freightdetail.tare_weight, 
		completion_freightdetail.tare_weightunit, 
		completion_freightdetail.fgt_pallets_in, 
		completion_freightdetail.fgt_pallets_out, 
		completion_freightdetail.fgt_pallets_on_trailer, 
		completion_freightdetail.fgt_carryins1,
		completion_freightdetail.fgt_carryins2, 
		completion_freightdetail.fgt_stackable, 
		completion_freightdetail.fgt_ratingquantity, 
		completion_freightdetail.fgt_ratingunit, 
		completion_freightdetail.fgt_quantity_type, 
		completion_freightdetail.fgt_ordered_count, 
		completion_freightdetail.fgt_ordered_weight, 
		completion_freightdetail.tar_number, 
		completion_freightdetail.tar_tariffnumber, 
		completion_freightdetail.tar_tariffitem, 
		completion_freightdetail.fgt_charge_type, 
		completion_freightdetail.fgt_rate_type, 
		completion_freightdetail.fgt_loadingmeters, 
		completion_freightdetail.fgt_loadingmetersunit, 
		completion_freightdetail.fgt_additionl_description, 
		completion_freightdetail.fgt_specific_flashpoint, 
		completion_freightdetail.fgt_specific_flashpoint_unit, 
		completion_freightdetail.fgt_ordered_volume, 
		completion_freightdetail.fgt_ordered_loadingmeters, 
		completion_freightdetail.fgt_pallet_type,  
		completion_freightdetail.cpr_density, 
		completion_freightdetail.scm_subcode, 
		completion_freightdetail.fgt_terms, 
		completion_freightdetail.fgt_consignee, 
		completion_freightdetail.fgt_shipper, 
		completion_freightdetail.fgt_leg_origin, 
		completion_freightdetail.fgt_leg_dest, 
		completion_freightdetail.fgt_count2, 
		completion_freightdetail.fgt_count2unit, 
		completion_freightdetail.fgt_bolid, 
		completion_freightdetail.fgt_bol_status, 
		completion_freightdetail.fgt_osdreason, 
		completion_freightdetail.fgt_osdquantity, 
		completion_freightdetail.fgt_osdunit, 
		completion_freightdetail.fgt_osdcomment, 
		completion_freightdetail.fgt_packageunit,
		completion_freightdetail.fgt_completion_supplier_id,
		completion_freightdetail.fgt_completion_accountof,
		completion_freightdetail.fgt_completion_netamt,
		completion_freightdetail.fgt_volumeunit,
		completion_freightdetail.fgt_completion_sequence,
		completion_freightdetail.fgt_parentcmd_number
	FROM 	completion_freightdetail
	WHERE	completion_freightdetail.stp_number = @v_cur_stp_number
	--Insert Freightdetails


	SET @v_return_code = @@error

	If @v_return_code <> 0
	 BEGIN
		Rollback Tran
		Return - 8
	 END

 END
--Insert Stops

--Insert Invoicedetails
SELECT	@v_ord_billto = ord_billto
FROM	completion_orderheader
WHERE	ord_hdrnumber = @p_ord_hdrnumber

--FMM 3/21/07 better performing query
--If Not Exists (select * from invoiceheader where ord_hdrnumber = @p_ord_hdrnumber)
IF (SELECT COUNT(*) FROM invoiceheader WHERE ord_hdrnumber = @p_ord_hdrnumber) = 0
 BEGIN	
	INSERT INTO invoicedetail(
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
		ivd_billable_flag)

	SELECT	0,					--ivh_hdrnumber
		ivd_number, 
		stp_number, 
		ivd_description, 
		completion_invoicedetail.cht_itemcode, 
		ivd_quantity, 
		IsNull(ivd_rate, 0),						
		IsNull(ivd_charge, 0),					
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
		@v_ord_billto, 
		ivd_itemquantity, 
		ivd_subtotalptr, 
		ivd_allocatedrev, 
		999, -- 38953 ivd_sequence, 
		ivd_invoicestatus, 
		mfh_hdrnumber, 
		ivd_refnum, 
		cmd_code, 
		'UNKNOWN',				--cmp_id (this is for accessorials - this may change)
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
		1, --ivd_sign
		ivd_length, 
		ivd_lengthunit, 
		ivd_width, 
		ivd_widthunit, 
		ivd_height, 
		ivd_heightunit, 
		ivd_exportstatus, 
		chargetype.cht_basisunit  cht_basisunit, 
		ivd_remark, 
		tar_number, 
		tar_tariffnumber, 
		tar_tariffitem, 
		'Y',					--ivd_fromord
		ivd_zipcode, 
		ivd_quantity_type, 
		completion_invoicedetail.cht_class, 
		ivd_mileagetable, 
		ivd_charge_type, 
		ivd_trl_rent, 
		ivd_trl_rent_start, 
		ivd_trl_rent_end, 
		ivd_rate_type, 
		chargetype.cht_lh_min cht_lh_min, 
		chargetype.cht_lh_rev cht_lh_rev, 
		chargetype.cht_lh_stl cht_lh_stl, 
		chargetype.cht_lh_rpt cht_lh_rpt, 
		chargetype.cht_rollintolh cht_rollintolh, 
		chargetype.cht_lh_prn  cht_lh_prn, 
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
		completion_invoicedetail.last_updateby, 
		completion_invoicedetail.last_updatedate, 
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
		ivd_completion_billable_flag
	FROM	completion_invoicedetail,chargetype
	WHERE	completion_invoicedetail.ord_hdrnumber = @p_ord_hdrnumber and
			completion_invoicedetail.cht_itemcode = chargetype.cht_itemcode -- JD added this join to replace the many subselects.

	SET @v_return_code = @@error

	If @v_return_code <> 0
	 BEGIN
		Rollback Tran
		Return - 9
	 END

 END
--Insert Invoicedetails

--CGK PTS 57732 Insert the Freight Detail reference numbers back into the reference number table.
INSERT INTO referencenumber(
	ref_tablekey, 
	ref_type, 
	ref_number, 
	ref_typedesc, 
	ref_sequence, 
	ord_hdrnumber, 
	ref_table, 
	ref_sid, 
	ref_pickup, 
	last_updateby, 
	last_updatedate)
SELECT 	ref_tablekey, 
	ref_type, 
	ref_number, 
	ref_typedesc, 
	ref_sequence, 
	ord_hdrnumber, 
	ref_table, 
	ref_sid, 
	ref_pickup, 
	last_updateby, 
	last_updatedate
FROM 	#referencenumberfreightdetail
--WHERE	ord_hdrnumber = @p_ord_hdrnumber	-- NQIAO PTS 58560
--CGK End PTS 57732 


--BEGIN PTS 56334 SPN
--Insert Referencenumbers
--INSERT INTO referencenumber(
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
--FROM 	completion_referencenumber
--WHERE	ord_hdrnumber = @p_ord_hdrnumber

--SET @v_return_code = @@error
--END PTS 56334 SPN

If @v_return_code <> 0
 BEGIN
	Rollback Tran
	Return - 10
 END
ELSE
 BEGIN
	Commit Tran
 END
--Insert Orderheader
--Insert Referencenumbers

--Call Update Move
SELECT 	@v_mov_number = mov_number
FROM	orderheader
WHERE	ord_hdrnumber = @p_ord_hdrnumber

If (SELECT ord_status FROM	orderheader
		WHERE	ord_hdrnumber = @p_ord_hdrnumber) = 'CAN'
	exec update_move @v_mov_number
Else
	exec completion_update_move @v_mov_number

SELECT	@v_ord_shiftdate = ord_completion_shift_date,
		@v_ord_shiftid = ord_completion_shift_id
FROM	completion_orderheader
WHERE	ord_hdrnumber = @p_ord_hdrnumber

if exists (select * from stops where ord_hdrnumber = @p_ord_hdrnumber
and		stp_type = 'DRP'
and		cmd_code IS NULL) --JD check before the update is run 44372
UPDATE	stops
SET		cmd_code = 'UNKNOWN'
WHERE	ord_hdrnumber = @p_ord_hdrnumber
and		stp_type = 'DRP'
and		cmd_code IS NULL

--jg begin
IF @v_ord_shiftdate is not null or @v_ord_shiftid is not null
--jg end
UPDATE	legheader
SET		lgh_shiftdate = @v_ord_shiftdate,
		lgh_shiftnumber = @v_ord_shiftid
--WHERE	ord_hdrnumber = @p_ord_hdrnumber
WHERE	mov_number = @v_mov_number -- JD 36951

Return 1
GO
GRANT EXECUTE ON  [dbo].[create_tmw_order_from_completion_sp] TO [public]
GO
