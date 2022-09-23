SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[outbound204_dupcheck] @ob_204id_current	INT
AS  BEGIN

	DECLARE @lgh_number int
	DECLARE @current_creaded_dt datetime
	DECLARE @ordercount int

	DECLARE @ob_204id_prior int
	DECLARE @stop_count_current int
	DECLARE @stop_count_prior int
	DECLARE @stop_count_delta int
	DECLARE @fgt_count_current int
	DECLARE @fgt_count_prior int
	DECLARE @fgt_count_delta int
	DECLARE @note_count_current int
	DECLARE @note_count_prior int
	DECLARE @note_count_delta int
	DECLARE @ref_count_current int
	DECLARE @ref_count_prior int
	DECLARE @ref_count_delta int

	IF NOT EXISTS	(	SELECT	1
						FROM	generalinfo gi
						WHERE	gi.gi_name = 'Outbound204DupCheck'
								and gi.gi_string1 = 'Y'
					) BEGIN
		RETURN
	END

	--Get needed info for current request
	SELECT	@lgh_number = lgh_number,
			@current_creaded_dt = created_dt
	FROM	edi_outbound204_order eio
	WHERE	ob_204id = @ob_204id_current

	--SELECT '@lgh_number', @lgh_number

	IF @lgh_number IS NULL BEGIN
		RETURN
	END

	--Get the 2nd ob_204id to compare with
	SELECT TOP 1 @ob_204id_prior = ob_204id
	FROM	edi_outbound204_order
	WHERE	lgh_number = @lgh_number
			AND ob_204id <> @ob_204id_current
			AND created_dt < @current_creaded_dt
			--LTSL processor can set status to E, which means it never went out.  So make sure status is one in which it's been sent or not yet processed
			AND process_status IN ('Y', 'N')
	ORDER BY created_dt DESC

	--select '@ob_204id_prior', @ob_204id_prior

	SELECT  @ordercount = count(*)
	FROM	(	SELECT DISTINCT --[ob_204id],
						--created_dt,
						--[edi_code] c,
						[ord_number]
						,[ord_hdrnumber]
						,[ord_refnumber]
						,[ord_revtype1]
						,[ord_bookdate]
						,[ord_startdate]
						,[ord_completiondate]
						,[ob_cmp_id]
						,[ob_name]
						,[ob_address1]
						,[ob_address2]
						,[ob_city]
						,[ob_state]
						,[ob_zip]
						,[sh_cmp_id]
						,[sh_name]
						,[sh_address1]
						,[sh_address2]
						,[sh_city]
						,[sh_state]
						,[sh_zip]
						,[cn_cmp_id]
						,[cn_name]
						,[cn_address1]
						,[cn_address2]
						,[cn_city]
						,[cn_state]
						,[cn_zip]
						,[car_id]
						,[ord_terms]
						,[car_edi_scac]
						,CASE [edi_code] WHEN '04' THEN '00' ELSE [edi_code] END edi_code
						--,[process_status]
						,[car_mileage]
						,[car_charge]
						,[broker_linehaul_charge]
						,[broker_fuel_charge]
						,[broker_accessorial_charge]
						,[broker_total_charge]
						,[ord_remark]
						,[sh_location_code]
						,[cn_location_code]
						,[ob_location_code]
						,[sh_phone]
						,[cn_phone]
						,[ob_phone]
						,[sh_contact]
						,[cn_contact]
						,[ob_contact]
						,[sh_county]
						,[cn_county]
						,[ob_county]
						--,[trl_type1]  --This may be needed, but it was noted that this was null during a 204 update (edi_code = 04) in spite of it not being changed
						,[ord_extrainfo11]
						,[ship_conditions]
						,[lgh_number]
						,[edi_message_type]
						,[rtd_id]
						--,[ord_mintemp]  --Part of 66155 not ready to check into core.  Once 66155 is checked in, this is to be restored.
						--,[ord_maxtemp]
						--,[ord_tempunits]
						--,[ord_totalweightunits]
						--,[ord_totalcountunits]
						--,[rail_load_type]
						--,[ord_totalcount]
						--,[ord_totalweight]
						--,[rs_international]
					FROM edi_outbound204_order
					WHERE	(	[ob_204id] = @ob_204id_current
								OR [ob_204id] = @ob_204id_prior
							)
			) distinctitems

	--select @ordercount

	IF @ordercount > 1 BEGIN --differences found
		RETURN 
	END

	SELECT	@stop_count_current = count(*)
	FROM	[dbo].[edi_outbound204_stops]
	WHERE	ob_204id = @ob_204id_current

	SELECT	@stop_count_prior = count(*)
	FROM	[dbo].[edi_outbound204_stops]
	WHERE	ob_204id = @ob_204id_prior

	IF @stop_count_current <> @stop_count_prior BEGIN
		RETURN
	END

	SELECT  @stop_count_delta = count(*)
	FROM	(	SELECT	DISTINCT --[ob_204id]
						[ord_hdrnumber]
						,[stp_number]
						,[cmp_id]
						,[cmp_name]
						,[cmp_address1]
						,[cmp_address2]
						,[cmp_city]
						,[cmp_state]
						,[cmp_zip]
						,[stp_sequence]
						,[stp_event]
						,[stp_weight]
						,[stp_weightunit]
						,[stp_count]
						,[stp_countunit]
						,[stp_volume]
						,[stp_volumeunit]
						,[stp_arrivaldate]
						,[stp_departuredate]
						,[stp_schdtearliest]
						,[stp_schdtlatest]
						,[cmp_location_code]
						,[stp_trailer1]
						,[stp_trailer2]
						,[cmp_phone]
						,[cmp_contact]
						,[cmp_county]
						,[stp_trailertype]
						--,[stp_trailer3] --Part of 66155 not ready to check into core.  Once 66155 is checked in, this is to be restored.
						--,[stp_trailer4]
				FROM	[dbo].[edi_outbound204_stops]
				WHERE	(	[ob_204id] = @ob_204id_current
							OR [ob_204id] = @ob_204id_prior
						)
			) distinctitems

	--select @stop_count_current, @stop_count_delta

	IF @stop_count_current <> @stop_count_delta BEGIN
		RETURN 
	END


	SELECT	@fgt_count_current = count(*)
	FROM	[dbo].[edi_outbound204_fgt]
	WHERE	ob_204id = @ob_204id_current

	SELECT	@fgt_count_prior = count(*)
	FROM	[dbo].[edi_outbound204_fgt]
	WHERE	ob_204id = @ob_204id_prior

	IF @fgt_count_current <> @fgt_count_prior BEGIN
		RETURN
	END

	SELECT  @fgt_count_delta = count(*) --*
	FROM	(	
				SELECT DISTINCT --[ob_204id]
						[ord_hdrnumber]
						,[stp_number]
						,[fgt_number]
						,[fgt_sequence]
						,[fgt_count]
						,[fgt_countunit]
						,[fgt_weight]
						,[fgt_weightunit]
						,[fgt_volume]
						,[fgt_volumeunit]
						,[fgt_rate]
						,[fgt_rateunit]
						,[fgt_charge]
						,[cmd_code]
						,[fgt_description]
						,[fgt_actual_quantity]
						,[fgt_actual_unit]
						,[edi_commodity]
						,[commodity_stcc]
						,[cmd_haz_num]
						--,[shipping_name] --Part of 66155 not ready to check into core.  Once 66155 is checked in, this is to be restored.
						--,[cmd_imdg_class]
						--,[cmd_imdg_packaginggroup]
						--,[fgt_hazmat_class_qualifier]
						--,[fgt_hazmat_shipping_name_qualifier]
				FROM	[dbo].[edi_outbound204_fgt]
				WHERE	(	[ob_204id] = @ob_204id_current
							OR [ob_204id] = @ob_204id_prior
						)
			) distinctitems

	--select @fgt_count_current, @fgt_count_delta

	IF @fgt_count_current <> @fgt_count_delta BEGIN
		RETURN 
	END


	SELECT	@note_count_current = count(*)
	FROM	[dbo].[edi_outbound204_notes]
	WHERE	ob_204id = @ob_204id_current

	SELECT	@note_count_prior = count(*)
	FROM	[dbo].[edi_outbound204_notes]
	WHERE	ob_204id = @ob_204id_prior

	IF @note_count_current <> @note_count_prior BEGIN
		RETURN
	END

	SELECT  @note_count_delta = count(*) --*
	FROM	(	
				SELECT DISTINCT --[ob_204id]
						[ord_hdrnumber]
						,[not_sentby]
						,[ntb_table]
						,[nre_tablekey]
						,[not_type]
						,[not_sequence]
						,[not_text]
				FROM [dbo].[edi_outbound204_notes]
				WHERE	(	[ob_204id] = @ob_204id_current
							OR [ob_204id] = @ob_204id_prior
						)
			) distinctitems

	--select @note_count_current, @note_count_delta

	IF @note_count_current <> @note_count_delta BEGIN
		RETURN 
	END


	SELECT	@ref_count_current = count(*)
	FROM	[dbo].[edi_outbound204_refs]
	WHERE	ob_204id = @ob_204id_current

	SELECT	@ref_count_prior = count(*)
	FROM	[dbo].[edi_outbound204_refs]
	WHERE	ob_204id = @ob_204id_prior

	IF @ref_count_current <> @ref_count_prior BEGIN
		RETURN
	END

	SELECT  @ref_count_delta = count(*) --*
	FROM	(	
				SELECT DISTINCT --[ob_204id]
						[ord_hdrnumber]
						,[ref_tablekey]
						,[ref_table]
						,[ref_sequence]
						,[ref_type]
						,[ref_number]
				FROM [dbo].[edi_outbound204_refs]
				WHERE	(	[ob_204id] = @ob_204id_current
							OR [ob_204id] = @ob_204id_prior
						)
			) distinctitems

	--select @ref_count_current, @ref_count_delta

	IF @ref_count_current <> @ref_count_delta BEGIN
		RETURN 
	END

	--print  'Nothing changed, so remove the current one'
	UPDATE	edi_outbound204_order
	SET		process_status = 'D' --for Duplicate
	WHERE	[ob_204id] = @ob_204id_current

	/*
	DELETE	edi_outbound204_refs
	WHERE	[ob_204id] = @ob_204id_current

	DELETE	edi_outbound204_notes
	WHERE	[ob_204id] = @ob_204id_current

	DELETE	edi_outbound204_fgt
	WHERE	[ob_204id] = @ob_204id_current

	DELETE	edi_outbound204_stops
	WHERE	[ob_204id] = @ob_204id_current

	DELETE	edi_outbound204_order
	WHERE	[ob_204id] = @ob_204id_current
	*/

END 
GO
GRANT EXECUTE ON  [dbo].[outbound204_dupcheck] TO [public]
GO
