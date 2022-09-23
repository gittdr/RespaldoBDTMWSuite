SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--PTS 46682 JJF 20110515
CREATE PROCEDURE [dbo].[intercompany_ico_child_copy_additional]	(
	@lgh_number_parent int,
	@lgh_number_child int,
	@ord_billto_child varchar(8),
	@revtype1_child varchar(6),
	@revtype2_child varchar(6),
	@revtype3_child varchar(6),
	@revtype4_child varchar(6),
	@car_id varchar(8),
	@trailer1_id varchar(13),
	--PTS 61653 JJF 20120619
	@ord_booked_revtype1_child varchar(12)
	--END PTS 61653 JJF 20120619
	
) 
AS BEGIN
	
	
	DECLARE	@newivdnbr_start int
	DECLARE @ivd_count int
	DECLARE	@ivd_ptr int
	DECLARE @pyd_xref_ptr int	
	DECLARE @stp_number_child int
	DECLARE @stp_number_parent int
	DECLARE @stp_mfh_sequence_child int
	DECLARE @stp_mfh_sequence_parent int
	DECLARE @mov_number_child int
	DECLARE @mov_number_parent int

	--JJF onsight hotfix 20110706
	DECLARE	@proc_to_call	varchar(50)		
	
	DECLARE @stopsupdate_child TABLE (
		stp_number int NULL,
		stp_mfh_sequence int NULL,
		stp_event varchar(6) NULL
	)

	DECLARE @stopsupdate_parent TABLE (
		stp_number int NULL,
		stp_mfh_sequence int NULL,
		stp_event varchar(6) NULL
	)

	SELECT	@mov_number_child = mov_number
	FROM	legheader
	WHERE	lgh_number = @lgh_number_child

	SELECT	@mov_number_parent = mov_number
	FROM	legheader
	WHERE	lgh_number = @lgh_number_parent
	
	UPDATE	event
	SET		evt_carrier = @car_id,
			evt_trailer1 = @trailer1_id,
			skip_trigger = 1
	FROM	event
			inner join legheader lgh on lgh.mov_number = event.evt_mov_number
	WHERE	lgh.lgh_number = @lgh_number_child

	UPDATE	stops
	SET		trl_id = @trailer1_id,
			skip_trigger = 1
	WHERE	lgh_number = @lgh_number_child
	
	----PTS 58953 JJF 20110913 ICORevTypeSource
	----Note that this should be temporary and will eventually be set and passed in via parameters.
	--SELECT @revtype1_child =	CASE	(	SELECT	gi_string1
	--										FROM	generalinfo
	--										WHERE	gi_name = 'ICORevTypeSource'
	--									)
	--								WHEN 2 THEN
	--									(	SELECT	cmp_revtype1
	--										FROM	company
	--										WHERE	cmp_id = @ord_billto_child
	--									)
	--								ELSE @revtype1_child
	--							END
	--									
	--SELECT @revtype2_child =	CASE	(	SELECT	gi_string2
	--										FROM	generalinfo
	--										WHERE	gi_name = 'ICORevTypeSource'
	--									)
	--								WHEN 2 THEN
	--									(	SELECT	cmp_revtype2
	--										FROM	company
	--										WHERE	cmp_id = @ord_billto_child
	--									)
	--								ELSE @revtype2_child
	--							END
	--SELECT @revtype3_child =	CASE	(	SELECT	gi_string3
	--										FROM	generalinfo
	--										WHERE	gi_name = 'ICORevTypeSource'
	--									)
	--								WHEN 2 THEN
	--									(	SELECT	cmp_revtype3
	--										FROM	company
	--										WHERE	cmp_id = @ord_billto_child
	--									)
	--								ELSE @revtype3_child
	--							END
	--SELECT @revtype4_child =	CASE	(	SELECT	gi_string4
	--										FROM	generalinfo
	--										WHERE	gi_name = 'ICORevTypeSource'
	--									)
	--								WHEN 2 THEN
	--									(	SELECT	cmp_revtype4
	--										FROM	company
	--										WHERE	cmp_id = @ord_billto_child
	--									)
	--								ELSE @revtype4_child
	--							END
	----END PTS 58953 JJF 20110913 ICORevTypeSource	
	
	UPDATE	orderheader
	SET		ord_revtype1 = @revtype1_child,
			ord_revtype2 = @revtype2_child,
			ord_revtype3 = @revtype3_child,
			ord_revtype4 = @revtype4_child,
			ord_billto = @ord_billto_child,
			ord_company =	CASE	oh.ord_company
								--WHEN 'UNKNOWN' THEN @ord_billto_child
								WHEN 'UNKNOWN' THEN	(	SELECT	TOP 1 oh_p_inner.ord_billto
														FROM	orderheader oh_p_inner
																INNER JOIN legheader lgh_p_inner on lgh_p_inner.ord_hdrnumber = oh_p_inner.ord_hdrnumber
														WHERE	lgh_p_inner.lgh_number = @lgh_number_parent
													)
								ELSE oh.ord_company
							END,
			ord_contact = cmp_billto.cmp_contact,
			ord_fromorder = null,
			ord_carrier = @car_id,
			ord_trailer = @trailer1_id,
			ord_terms = 'THR',
			--PTS 61653 JJF 20120619
			ord_booked_revtype1 = @ord_booked_revtype1_child
			--END PTS 61653 JJF 20120619
	FROM	orderheader oh
			INNER JOIN legheader_active lgh on lgh.ord_hdrnumber = oh.ord_hdrnumber
			LEFT OUTER JOIN company cmp_billto on cmp_billto.cmp_id = @ord_billto_child
	WHERE	lgh.lgh_number = @lgh_number_child

	--Clean out existing invoicedetail created as a result of existing copy order functionality.  
	--These are replaced by converting paydetail from parent to invoicedetail.
	DELETE	invoicedetail
	FROM	invoicedetail ivd inner join legheader lgh on ivd.ord_hdrnumber = lgh.ord_hdrnumber
	WHERE	lgh.lgh_number = @lgh_number_child
	
	
	--Walk through stops and link corresponding stops parent to child
	INSERT	@stopsupdate_child
	SELECT DISTINCT stp_c.stp_number, stp_c.stp_mfh_sequence, stp_c.stp_event
	FROM	stops stp_c 
	WHERE	stp_c.lgh_number = @lgh_number_child
	ORDER BY stp_c.stp_mfh_sequence			
	
	INSERT	@stopsupdate_parent
	SELECT DISTINCT stp_p.stp_number, stp_p.stp_mfh_sequence, stp_p.stp_event
	FROM	stops stp_p
	WHERE	stp_p.lgh_number = @lgh_number_parent
	ORDER BY stp_p.stp_mfh_sequence
	
	
	SELECT	@stp_mfh_sequence_child = MIN(stp_mfh_sequence)
	FROM	@stopsupdate_child
	

	SELECT	@stp_mfh_sequence_parent = MIN(stp_mfh_sequence)
	FROM	@stopsupdate_parent

	WHILE (@stp_mfh_sequence_child > 0) BEGIN
		IF (@stp_mfh_sequence_parent > 0) BEGIN
			
			SELECT	@stp_number_child = stp_number
			FROM	@stopsupdate_child
			WHERE	stp_mfh_sequence = @stp_mfh_sequence_child
			
			SELECT	@stp_number_parent = stp_number
			FROM	@stopsupdate_parent
			WHERE	stp_mfh_sequence = @stp_mfh_sequence_parent
			
			--update parent stop to link to corresponding child stop
			UPDATE	stops
			SET		stp_ico_stp_number_child = @stp_number_child,
					--stp_ico_stp_number_parent = null,
					skip_trigger = 1
			WHERE	stops.stp_number = @stp_number_parent
			
			--link child stop to link to corresponding parent stop
			UPDATE	stops
			SET		stp_ico_stp_number_parent = @stp_number_parent,
					--stp_ico_stp_number_child = null,
					skip_trigger = 1
			WHERE	stops.stp_number = @stp_number_child
			
			UPDATE	stops
			SET		cmp_id = stp_p.cmp_id,
					stp_region1 = stp_p.stp_region1,
					stp_region2 = stp_p.stp_region2,
					stp_region3 = stp_p.stp_region3,
					stp_city = stp_p.stp_city,
					stp_state = stp_p.stp_state,
					stp_schdtearliest = stp_p.stp_schdtearliest,
					stp_origschdt = stp_p.stp_origschdt,
					stp_arrivaldate = stp_p.stp_arrivaldate,
					stp_departuredate = stp_p.stp_departuredate,
					stp_reasonlate = stp_p.stp_reasonlate,
					stp_schdtlatest = stp_p.stp_schdtlatest,
					stp_region4 = stp_p.stp_region4,
					stp_event = CASE stp_p.stp_event
									WHEN 'HLT' THEN 'HPL'
									WHEN 'DLT' THEN 'DRL'
									ELSE stops.stp_event
								END,
					cmp_name = stp_p.cmp_name,
					stp_reftype = stp_p.stp_reftype,
					stp_refnum = stp_p.stp_refnum,
					stp_reasonlate_depart = stp_p.stp_reasonlate_depart,
					stp_type1 = stp_p.stp_type1,
					stp_comment = stp_p.stp_comment,
					stp_phonenumber = stp_p.stp_phonenumber,
					stp_zipcode = stp_p.stp_zipcode,
					stp_address = stp_p.stp_address,
					stp_country = stp_p.stp_country,
					stp_phonenumber2 = stp_p.stp_phonenumber2,
					stp_address2 = stp_p.stp_address2,
					stp_contact = stp_p.stp_contact,
					stp_podname = stp_p.stp_podname,
					stp_custpickupdate = stp_p.stp_custpickupdate,
					stp_custdeliverydate = stp_p.stp_custdeliverydate,
					stp_activitystart_dt = stp_p.stp_activitystart_dt,
					stp_activityend_dt = stp_p.stp_activityend_dt,
					stp_reasonlate_text = stp_p.stp_reasonlate_text,
					stp_reasonlate_depart_text = stp_p.stp_reasonlate_depart_text,
					stp_eta = stp_p.stp_eta,
					stp_etd = stp_p.stp_etd,
					--PTS 58475 JJF 20110826
					stp_origarrival = stp_p.stp_origarrival,
					stp_ord_mileage = stp_p.stp_ord_mileage,
					stp_lgh_mileage = stp_p.stp_lgh_mileage,
					stp_trip_mileage = stp_p.stp_trip_mileage
					--END PTS 58475 JJF 20110826
					--skip_trigger = 1
			FROM	stops
					INNER JOIN stops stp_p on stp_p.stp_number = stops.stp_ico_stp_number_parent
			WHERE	stops.stp_number = @stp_number_child
			
			--Ensure all reference numbers from parent stops transfer correctly to child stops
			DELETE	referencenumber
			FROM	referencenumber 
					INNER JOIN stops stp_c on (referencenumber.ref_table = 'stops' and referencenumber.ref_tablekey = stp_c.stp_number)
			WHERE	stp_c.stp_number = @stp_number_child

			INSERT	referencenumber	(
						ref_tablekey,
						ref_type,
						ref_number,
						ref_typedesc,
						ref_sequence,
						ord_hdrnumber,
						ref_table,
						ref_sid,
						ref_pickup
					)
			SELECT	stp_c.stp_number,
					ref_p.ref_type,
					ref_p.ref_number,
					ref_p.ref_typedesc,
					ref_p.ref_sequence,
					oh_c.ord_hdrnumber,
					ref_p.ref_table,
					ref_p.ref_sid,
					ref_p.ref_pickup
			FROM	stops stp_c
					INNER JOIN stops stp_p on stp_c.stp_ico_stp_number_parent = stp_p.stp_number
					INNER JOIN referencenumber ref_p on (ref_p.ref_table = 'stops' and ref_p.ref_tablekey = stp_p.stp_number)
					INNER JOIN orderheader oh_c on oh_c.mov_number = stp_c.mov_number
			WHERE	stp_c.stp_number = @stp_number_child
				
		END
		
		SELECT	@stp_mfh_sequence_child = MIN(stp_mfh_sequence)
		FROM	@stopsupdate_child
		WHERE	stp_mfh_sequence > @stp_mfh_sequence_child
	

		SELECT	@stp_mfh_sequence_parent = MIN(stp_mfh_sequence)
		FROM	@stopsupdate_parent
		WHERE	stp_mfh_sequence > @stp_mfh_sequence_parent
	END
		
	--Copy parent paydetail that maps to child invoicedetail - all but leg based, 
	CREATE TABLE	#pyd_xref	(
		pyd_xref_id			int IDENTITY(1,1) NOT NULL,
		pyd_number_parent	int	NULL,
		ivd_number_child	int NULL
	)

	INSERT INTO #pyd_xref	(
			pyd_number_parent
	)
	SELECT	pyd.pyd_number
	FROM	paydetail pyd
			INNER JOIN paytype pyt ON pyd.pyt_itemcode = pyt.pyt_itemcode 
	WHERE	pyd.lgh_number = @lgh_number_parent
			AND ISNULL(pyt.cht_itemcode, 'UNK') <> 'UNK'
			AND pyt.pyt_basis <> 'LGH'
	
	
	SELECT @ivd_count = count(*)
	FROM #pyd_xref
	
	EXEC @newivdnbr_start = getsystemnumberblock 'INVDET', NULL, @ivd_count
	IF @@ERROR <> 0 GOTO ERROR_EXIT2

	
	UPDATE 	#pyd_xref
	SET		ivd_number_child = (@newivdnbr_start + (pyd_xref_id - 1))

	
	SELECT	@pyd_xref_ptr = MIN(pyd_xref_id)
	FROM	#pyd_xref

	WHILE	ISNULL(@pyd_xref_ptr, 0) > 0 BEGIN

		INSERT INTO invoicedetail	(
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
				--ivd_allocatedrev,
				ivd_sequence,
				ivd_invoicestatus,
				mfh_hdrnumber,
				--ivd_refnum,
				cmd_code,
				cmp_id,
				ivd_distance,
				ivd_distunit,
				ivd_wgt,
				ivd_wgtunit,
				ivd_count,
				ivd_countunit,
				--evt_number,
				ivd_reftype,
				ivd_volume,
				ivd_volunit,
				--ivd_orig_cmpid,
				--ivd_payrevenue,
				ivd_sign,
				--ivd_length,
				--ivd_lengthunit,
				--ivd_width,
				--ivd_widthunit,
				--ivd_height,
				--ivd_heightunit,
				ivd_exportstatus,
				cht_basisunit,
				--ivd_remark,
				--tar_number,
				--tar_tariffnumber,
				--tar_tariffitem,
				ivd_fromord,
				--ivd_zipcode,
				--ivd_quantity_type,
				cht_class,
				--ivd_mileagetable,
				ivd_charge_type,
				cht_lh_min,
				cht_lh_rev,
				cht_lh_stl,
				cht_lh_rpt,
				cht_rollintolh,
				--ivd_car_key,
				ivd_hide,
				ivd_ico_pyd_number_parent
		)  
		SELECT	0 ivh_hdrnumber,
				pxref.ivd_number_child,
				pyd.stp_number,
				cht.cht_description,
				pyt.cht_itemcode,
				pyd.pyd_quantity,
				pyd.pyd_rate,
				pyd.pyd_amount,
				cht.cht_taxtable1,
				cht.cht_taxtable2,
				cht.cht_taxtable3,
				cht.cht_taxtable4,
				cht.cht_unit,
				cht.cht_currunit,
				GETDATE() ivd_currencydate,
				cht.cht_glnum,
				oh_c.ord_hdrnumber,
				'LI' ivd_type,
				cht.cht_rateunit,
				oh_c.ord_billto,
				0 ivd_itemquantity,
				0 ivd_subtotalptr,
				--i.ivd_allocatedrev,
				999 ivd_sequence,
				'HLD' ivd_invoicestatus,
				NULL mfh_hdrnumber,
				--i.ivd_refnum,
				'UNKNOWN' cmd_code,
				'UNKNOWN' cmp_id,
				0 ivd_distance,
				'MIL' ivd_distunit,
				0 ivd_wgt,
				'LBS' ivd_wgtunit,
				0 ivd_count,
				'PCS' ivd_countunit,
				--ex.new_evt_number,
				'UNK' ivd_reftype,
				0 ivd_volume,
				'CUB' ivd_volunit,
				--i.ivd_orig_cmpid,
				--i.ivd_payrevenue,
				1 ivd_sign,
				--i.ivd_length,
				--i.ivd_lengthunit,
				--i.ivd_width,
				--i.ivd_widthunit,
				--i.ivd_height,
				--i.ivd_heightunit,
				NULL ivd_exportstatus,
				cht.cht_basisunit,
				--i.ivd_remark,
				--i.tar_number,
				--i.tar_tariffnumber,
				--i.tar_tariffitem,
				'D' ivd_fromord,
				--i.ivd_zipcode,
				--i.ivd_quantity_type,
				cht.cht_class,
				--i.ivd_mileagetable,
				0 ivd_charge_type,
				cht.cht_lh_min,
				cht.cht_lh_rev,
				cht.cht_lh_stl,
				cht.cht_lh_rpt,
				cht.cht_rollintolh,
				--i.ivd_car_key,
				'N' ivd_hide,
				pyd_number_parent
		FROM	#pyd_xref pxref
				INNER JOIN paydetail pyd ON pxref.pyd_number_parent = pyd.pyd_number
				INNER JOIN paytype pyt ON pyd.pyt_itemcode = pyt.pyt_itemcode
				INNER JOIN chargetype cht ON pyt.cht_itemcode = cht.cht_itemcode
				CROSS JOIN legheader lgh_child
				INNER JOIN orderheader oh_c on oh_c.mov_number = lgh_child.mov_number
		WHERE	pxref.pyd_xref_id = @pyd_xref_ptr
				AND lgh_child.lgh_number = @lgh_number_child
				AND ISNULL(pyt.cht_itemcode, 'UNK') <> 'UNK'

		SELECT	@pyd_xref_ptr = MIN(pyd_xref_id)
		FROM	#pyd_xref
		WHERE	pyd_xref_id > @pyd_xref_ptr
	END
			
	UPDATE	orderheader
	SET		ord_totalcharge = pyd_amount,
			ord_quantity = 1,
			ord_rate = pyd_rate,
			ord_charge = pyd_amount,
			ord_rateunit = cht.cht_rateunit,
			cht_itemcode = cht.cht_itemcode,
			--PTS 57876 JJF 20110708 
			--ord_accessorial_chrg =	(	SELECT	sum(isnull(ivdinner.ivd_charge, 0))
			--							FROM	invoicedetail ivdinner
			--							WHERE	ivdinner.ord_hdrnumber = orderheader.ord_hdrnumber
			--						)
			ord_accessorial_chrg =	ISNULL	(	(	SELECT	sum(isnull(ivdinner.ivd_charge, 0))
													FROM	invoicedetail ivdinner
													WHERE	ivdinner.ord_hdrnumber = orderheader.ord_hdrnumber
												), 0
											)
			--END PTS 57876 JJF 20110708 
	FROM	paydetail pyd
			INNER JOIN paytype pyt ON pyd.pyt_itemcode = pyt.pyt_itemcode 
			INNER JOIN chargetype cht on cht.cht_itemcode = pyt.cht_itemcode
	WHERE	orderheader.mov_number = @mov_number_child
			and pyd.lgh_number = @lgh_number_parent
			and pyt.pyt_basis = 'LGH'
			
					

	INSERT	referencenumber	(
				ref_tablekey,
				ref_type,
				ref_number,
				ref_typedesc,
				ref_sequence,
				ord_hdrnumber,
				ref_table,
				ref_sid,
				ref_pickup
			)
	SELECT	oh_c.ord_hdrnumber,
			ref_p.ref_type,
			ref_p.ref_number,
			ref_p.ref_typedesc,
			ref_p.ref_sequence,
			oh_c.ord_hdrnumber,
			ref_p.ref_table,
			ref_p.ref_sid,
			ref_p.ref_pickup
	FROM	orderheader oh_p 
			INNER JOIN referencenumber ref_p on (ref_p.ref_table = 'orderheader' and ref_p.ref_tablekey = oh_p.ord_hdrnumber),
			orderheader oh_c 
	WHERE	oh_c.mov_number = @mov_number_child
			and oh_p.mov_number = @mov_number_parent
	
	UPDATE	orderheader
	SET		ord_reftype = oh_p.ord_reftype,
			ord_refnum = oh_p.ord_refnum
	FROM	orderheader,
			orderheader oh_p
	WHERE	orderheader.mov_number = @mov_number_child
			and oh_p.mov_number = @mov_number_parent
												

	IF @@ERROR <> 0		BEGIN
		GOTO ERROR_EXIT
	END

	

	UPDATE	paydetail
	SET		pyd_ico_ivd_number_child = ivd_number_child
	FROM	#pyd_xref
	WHERE	paydetail.pyd_number = #pyd_xref.pyd_number_parent
	
	UPDATE	paydetail
	SET		pyd_ico_ivd_number_child = -1
	FROM	paydetail 
			INNER JOIN paytype pyt ON paydetail.pyt_itemcode = pyt.pyt_itemcode 
			INNER JOIN chargetype cht on cht.cht_itemcode = pyt.cht_itemcode
	WHERE	paydetail.lgh_number = @lgh_number_parent
			and pyt.pyt_basis = 'LGH'


	exec dbo.update_assetassignment @mov_number_child
	
	exec dbo.update_move_light @mov_number_child


	--PTS 57842 JJF 20110706
	SELECT	@proc_to_call = isnull(ltrim(rtrim(gi_string1)), '')
	FROM	generalinfo 
	WHERE	gi_name = 'ICOCreateOrderPostProcessing'

	IF @proc_to_call <> '' BEGIN
			exec @proc_to_call 
					@lgh_number_parent,
					@lgh_number_child,
					@mov_number_parent,
					@mov_number_child
	END
	--END PTS 57842 JJF 20110706
	

	
	GOTO SUCCESS_EXIT

ERROR_EXIT:
--  ROLLBACK TRAN COPYLOOP

ERROR_EXIT2:

SUCCESS_EXIT:
	drop table #pyd_xref

END
GO
GRANT EXECUTE ON  [dbo].[intercompany_ico_child_copy_additional] TO [public]
GO
