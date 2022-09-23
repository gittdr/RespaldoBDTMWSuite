SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--PTS 46682 JJF 20110515
CREATE PROCEDURE [dbo].[intercompany_ico_sync_child_to_parent_sp]	(
	@mov_number_child int
) 

AS BEGIN

	--return
	DECLARE @debug varchar(1)
	
	SELECT @debug = 'N'
	
	IF @debug = 'Y' BEGIN
		print 'start intercompany_ico_sync_child_to_parent_sp'
	END		
	
	
	--Push changes on child trips to parent
	DECLARE @mov_number_parent int
	DECLARE @evt_number_parent  int
	DECLARE @stp_number_parent int
	DECLARE @lgh_number_child int
	DECLARE @lgh_number_bottom_child int
	DECLARE @lgh_number_next int
	DECLARE	@lgh_outstatus_bottom_child varchar(6)

	DECLARE @fgt_newcount int
	DECLARE @new_fgtnbr_next int
	DECLARE @new_fgtnbr_start int
	DECLARE @fgt_sequence_next int

	DECLARE @evt_newcount int
	DECLARE @new_evtnbr_next int
	DECLARE @new_evtnbr_start int
	DECLARE @evt_sequence_next int
			
	DECLARE @eventupdate_parent TABLE	(
		evt_number int NULL
	)

	DECLARE @stopsupdate_parent TABLE (
		stp_number int NULL,
		stp_ico_stp_number_child int
	)
	
	DECLARE @legheaderupdate_child TABLE (
		lgh_number int NULL
	)

	
	--PTS 46682 JJF 20110512
	IF EXISTS	(	SELECT	*
					FROM	stops stp_c
					WHERE	stp_c.mov_number = @mov_number_child
							and stp_c.stp_ico_stp_number_parent > 0
				) BEGIN
				
		--PTS 57971 JJF 20110715 JJF total mail relies on calling update_ord to sync status, but it's called after update_move
		exec update_ord  @mov_number_child, 'CMP'				
		--END PTS 57971 JJF 20110715 JJF total mail relies on calling update_ord to sync status, but it's called after update_move
		
		SELECT DISTINCT @mov_number_parent = stp_p.mov_number
		FROM	stops stp_c
				INNER JOIN stops stp_p on stp_c.stp_ico_stp_number_parent = stp_p.stp_number
		WHERE	stp_c.mov_number = @mov_number_child
				and stp_c.stp_ico_stp_number_parent > 0

		IF @debug = 'Y' BEGIN
			select 'before changes...', @mov_number_parent mov_number_parent, @mov_number_child mov_number_child
			--EXEC intercompany_diagnostic @mov_number_parent, @mov_number_child
			print 'syncing...'
		END
	
				
		--Loop through trips...based on status, make parent available, or update events/stops
		INSERT	@legheaderupdate_child
		SELECT	DISTINCT stp_c.lgh_number
		FROM	stops stp_c
		WHERE	stp_c.mov_number = @mov_number_child
				AND isnull(stp_c.stp_ico_stp_number_parent, 0) > 0
				
		SELECT	@lgh_number_child = MIN(lgh_number)
		FROM	@legheaderupdate_child


		WHILE (@lgh_number_child > 0) BEGIN
			--find this trip's bottom most segment
			IF @debug = 'Y' BEGIN
				select 'working on @@lgh_number_child', @lgh_number_child
			END				

			SELECT @lgh_number_bottom_child = @lgh_number_child
			--SELECT @lgh_number_next = @lgh_number_bottom_child
			--
			--WHILE @lgh_number_next > 0  BEGIN
			--
			--	SELECT  @lgh_number_next = 0
			--	
			--	SELECT	@lgh_number_next = stp_c.lgh_number
			--	FROM	legheader lgh_p
			--			inner join stops stp_p on lgh_p.lgh_number = stp_p.lgh_number
			--			LEFT OUTER JOIN stops stp_c on stp_c.stp_number = stp_p.stp_ico_stp_number_child
			--	WHERE	lgh_p.lgh_number = @lgh_number_bottom_child
			--
			--	IF ISNULL(@lgh_number_next, 0) > 0 BEGIN
			--		SELECT @lgh_number_bottom_child = @lgh_number_next
			--	END
			--END

			SELECT @lgh_outstatus_bottom_child = 'CAN'
			
			SELECT	@lgh_outstatus_bottom_child = lgh_outstatus
			FROM	legheader lgh_c
			WHERE	lgh_c.lgh_number = @lgh_number_bottom_child
			
			
			SELECT @lgh_outstatus_bottom_child = ISNULL(@lgh_outstatus_bottom_child, 'CAN')

			IF @debug = 'Y' BEGIN								
				select '@lgh_number_bottom_child', @lgh_number_bottom_child
				select '@lgh_outstatus_bottom_child', @lgh_outstatus_bottom_child
			END		
			
			--Get list of parent events to update
			DELETE @eventupdate_parent
			
			INSERT	@eventupdate_parent
			SELECT	DISTINCT event.evt_number
			FROM	stops stp_c
					inner join stops stp_p on stp_c.stp_ico_stp_number_parent = stp_p.stp_number
					INNER JOIN event on stp_p.stp_number = event.stp_number 
			WHERE	stp_c.lgh_number = @lgh_number_child

			IF @debug = 'Y' BEGIN
				print 'select * from @eventupdate'	
				select * from @eventupdate_parent
			END
			
			SELECT	@evt_number_parent = MIN(evt_number)
			FROM	@eventupdate_parent
			
			WHILE (@evt_number_parent > 0) BEGIN
				--update parent event for date/times
				IF @debug = 'Y' BEGIN
					select 'updating @evt_number_parent', @evt_number_parent
				END

				UPDATE	event
				SET		evt_startdate = evt_c.evt_startdate,
						evt_enddate = evt_c.evt_enddate,
						evt_status =	CASE	@lgh_outstatus_bottom_child
											WHEN 'CAN' THEN 'OPN'
											--WHEN 'AVL' THEN 'OPN'
											ELSE evt_c.evt_status
										END,
						evt_departure_status =	CASE @lgh_outstatus_bottom_child
													WHEN 'CAN' THEN 'OPN'
													--WHEN 'AVL' THEN 'OPN'
													ELSE evt_c.evt_departure_status
												END,
						evt_earlydate = evt_c.evt_earlydate,
						evt_latedate = evt_c.evt_latedate,
						evt_reason  = evt_c.evt_reason,
						evt_weightunit = evt_c.evt_weightunit,
						evt_countunit = evt_c.evt_countunit,
						evt_carrier =	CASE	@lgh_outstatus_bottom_child
							WHEN 'CAN' THEN 'UNKNOWN'
							--WHEN 'AVL' THEN 'UNKNOWN'
							ELSE event.evt_carrier
						END,
						evt_trailer1 =	CASE @lgh_outstatus_bottom_child
											WHEN 'CAN' THEN event.evt_trailer1
											WHEN 'AVL' THEN event.evt_trailer1
											ELSE evt_c.evt_trailer1
										END,
						evt_trailer2 =	CASE @lgh_outstatus_bottom_child
											WHEN 'CAN' THEN event.evt_trailer2
											WHEN 'AVL' THEN event.evt_trailer2
											ELSE evt_c.evt_trailer2
										END,
						evt_trailer3 =	CASE @lgh_outstatus_bottom_child
											WHEN 'CAN' THEN event.evt_trailer3
											WHEN 'AVL' THEN event.evt_trailer3
											ELSE evt_c.evt_trailer3
										END,
						evt_trailer4 =	CASE @lgh_outstatus_bottom_child
											WHEN 'CAN' THEN event.evt_trailer4
											WHEN 'AVL' THEN event.evt_trailer4
											ELSE evt_c.evt_trailer4
										END,

	/*
						evt_driver1 =	CASE	oh_c.ord_status
											--WHEN 'CAN' THEN 'UNKNOWN'
											--WHEN 'AVL' THEN 'UNKNOWN'
											ELSE event.evt_driver1
										END,
						evt_driver2 =	CASE	oh_c.ord_status
											--WHEN 'CAN' THEN 'UNKNOWN'
											--WHEN 'AVL' THEN 'UNKNOWN'
											ELSE event.evt_driver2
										END,
						evt_tractor =	CASE	oh_c.ord_status
											--WHEN 'CAN' THEN 'UNKNOWN'
											--WHEN 'AVL' THEN 'UNKNOWN'
											ELSE event.evt_tractor
										END,
						evt_chassis =	CASE	oh_c.ord_status
											--WHEN 'CAN' THEN 'UNKNOWN'
											--WHEN 'AVL' THEN 'UNKNOWN'
											ELSE event.evt_chassis
										END,
						evt_dolly =		CASE	oh_c.ord_status
											--WHEN 'CAN' THEN 'UNKNOWN'
											--WHEN 'AVL' THEN 'UNKNOWN'
											ELSE event.evt_dolly
										END,
						evt_chassis2 =	CASE	oh_c.ord_status
											--WHEN 'CAN' THEN 'UNKNOWN'
											--WHEN 'AVL' THEN 'UNKNOWN'
											ELSE event.evt_chassis2
										END,
						evt_dolly2 =	CASE	oh_c.ord_status
											--WHEN 'CAN' THEN 'UNKNOWN'
											--WHEN 'AVL' THEN 'UNKNOWN'
											ELSE event.evt_dolly2
										END,
	*/
						skip_trigger = 1
				FROM	event
						INNER JOIN stops stp_p on event.stp_number = stp_p.stp_number
						INNER JOIN stops stp_c on stp_p.stp_ico_stp_number_child = stp_c.stp_number
						INNER JOIN event evt_c on stp_c.stp_number = evt_c.stp_number
				WHERE	event.evt_number = @evt_number_parent
						and event.evt_sequence = evt_c.evt_sequence


				IF @debug = 'Y' BEGIN
					print 'deleting removed events...'
				END

				DELETE	event
				FROM	event
						INNER JOIN stops stp_p on event.stp_number = stp_p.stp_number
				WHERE	event.evt_number = @evt_number_parent
						AND NOT EXISTS	(	SELECT	*
											FROM	event evt_c_inner
											WHERE	evt_c_inner.stp_number = stp_p.stp_ico_stp_number_child
													and evt_c_inner.evt_sequence = event.evt_sequence
										)

				SELECT	@evt_number_parent = MIN(evt_number) 
				FROM	@eventupdate_parent
				WHERE	evt_number > @evt_number_parent
				
			END


			--Get list of parent stops to update
			DELETE	@stopsupdate_parent
			
			INSERT	@stopsupdate_parent
			SELECT DISTINCT stp_p.stp_number,
					stp_p.stp_ico_stp_number_child
			FROM	stops stp_p 
					inner join stops stp_c on stp_c.stp_ico_stp_number_parent = stp_p.stp_number
			WHERE	stp_c.lgh_number = @lgh_number_child

			IF @debug = 'Y' BEGIN
				print 'select * from @stopsupdate'
				select * from @stopsupdate_parent
			END
					
			--update parent stops
			--print 'update parent stops'
			SELECT	@stp_number_parent = MIN(stp_number)
			FROM	@stopsupdate_parent
			
			WHILE (@stp_number_parent > 0) BEGIN
				IF @debug = 'Y' BEGIN
					select 'updating @stp_number_parent', @stp_number_parent
				END

				--Determine number of events to add (number of child not in parent)
				
				SELECT	@evt_newcount = count(*)
				FROM	event evt_c
						INNER JOIN stops stp_c on evt_c.stp_number = stp_c.stp_number
						INNER JOIN stops stp_p on stp_p.stp_ico_stp_number_child = stp_c.stp_number
				WHERE	stp_p.stp_number = @stp_number_parent
						AND NOT EXISTS	(	SELECT	*
											FROM	event evt_p_inner
											WHERE	evt_p_inner.stp_number = stp_p.stp_number
													and evt_p_inner.evt_sequence = evt_c.evt_sequence
										)

				IF @debug = 'Y' BEGIN
					print 'number of new events to add...'
					print @evt_newcount
				END
				
				IF @evt_newcount > 0 BEGIN
				
					SELECT @evt_sequence_next = MAX(evt_p.evt_sequence) + 1
					FROM	event evt_p
							INNER JOIN stops stp_p on evt_p.stp_number = stp_p.stp_number
					WHERE	stp_p.stp_number = @stp_number_parent

					IF @debug = 'Y' BEGIN
						select  'New parent events starting sequence @evt_sequence_next', @evt_sequence_next
					END
		
					EXEC @new_evtnbr_start = dbo.getsystemnumberblock 'EVTNUM', NULL, @evt_newcount
					--IF @@ERROR <> 0 GOTO ERROR_EXIT2
			
					SELECT @new_evtnbr_next = @new_evtnbr_start
					
					select '@new_evtnbr_next', @new_evtnbr_next, '@new_evtnbr_start', @new_evtnbr_start, '@evt_newcount', @evt_newcount
					
					WHILE @new_evtnbr_next < @new_evtnbr_start + @evt_newcount  BEGIN
						IF @debug = 'Y' BEGIN
							select  'Adding New parent event @new_evtnbr_next', @new_evtnbr_next, 'sequence', @evt_sequence_next
						END

						INSERT	event	(
							evt_number, 
							stp_number, 
							evt_sequence,
							fgt_number,
							evt_mov_number,   
							evt_pu_dr, 
							evt_eventcode, 
							evt_status, 
							evt_departure_status, 
							evt_driver1, 
							evt_driver2, 
							evt_tractor, 
							evt_trailer1, 
							evt_trailer2, 
							evt_carrier, 
							evt_chassis, 
							evt_chassis2, 
							evt_dolly, 
							evt_dolly2, 
							evt_trailer3, 
							evt_trailer4 , 
							ord_hdrnumber, 
							evt_startdate, 
							evt_earlydate, 
							evt_latedate, 
							evt_enddate, 
							evt_reason, 
							evt_weight, 
							evt_weightunit, 
							evt_count, 
							evt_countunit, 
							skip_trigger) 
						SELECT	@new_evtnbr_next,
								@stp_number_parent,
								@evt_sequence_next,
								evt_p_primary.fgt_number,
								evt_p_primary.evt_mov_number,
								evt_c.evt_pu_dr,
								evt_c.evt_eventcode,
								evt_c.evt_status,
								evt_c.evt_departure_status,
								evt_p_primary.evt_driver1,
								evt_p_primary.evt_driver2,
								evt_p_primary.evt_tractor,
								evt_p_primary.evt_trailer1,
								evt_p_primary.evt_trailer2,
								evt_p_primary.evt_carrier,
								evt_p_primary.evt_chassis,
								evt_p_primary.evt_chassis2,
								evt_p_primary.evt_dolly,
								evt_p_primary.evt_dolly2,
								evt_p_primary.evt_trailer3,
								evt_p_primary.evt_trailer4,
								evt_p_primary.ord_hdrnumber,
								evt_c.evt_startdate,
								evt_c.evt_earlydate,
								evt_c.evt_latedate,
								evt_c.evt_enddate,
								evt_c.evt_reason,
								evt_c.evt_weight,
								evt_c.evt_weightunit,
								evt_c.evt_count,
								evt_c.evt_countunit,
								1
						FROM	stops stp_p
								INNER JOIN stops stp_c on stp_p.stp_ico_stp_number_child = stp_c.stp_number
								INNER JOIN event evt_c on evt_c.stp_number = stp_c.stp_number
								INNER JOIN event evt_p_primary on (evt_p_primary.stp_number = stp_p.stp_number and evt_p_primary.evt_sequence = 1)
						WHERE	stp_p.stp_number = @stp_number_parent
								and evt_c.evt_sequence = @evt_sequence_next

						
						
						SELECT @new_evtnbr_next = @new_evtnbr_next + 1
						SELECT @evt_sequence_next = @evt_sequence_next + 1
					END

				END				



				UPDATE	stops
				SET		stp_schdtearliest = stp_c.stp_schdtearliest,
						stp_arrivaldate = stp_c.stp_arrivaldate,
						stp_departuredate = stp_c.stp_departuredate,
						stp_schdtlatest = stp_c.stp_schdtlatest,
						stp_lgh_status =	CASE	@lgh_outstatus_bottom_child
												WHEN 'CAN' THEN 'AVL'
												WHEN 'AVL' THEN 'PLN'
												ELSE stp_c.stp_lgh_status
											END,
						stp_status =	CASE @lgh_outstatus_bottom_child
											WHEN 'CAN' THEN 'OPN'
											--WHEN 'AVL' THEN 'OPN'
											
											ELSE stp_c.stp_status
										END,
						stp_departure_status =	CASE @lgh_outstatus_bottom_child
													WHEN 'CAN' THEN 'OPN'
													--WHEN 'AVL' THEN 'OPN'
													ELSE stp_c.stp_departure_status
												END,
						stp_comment = stp_c.stp_comment,
						stp_reasonlate = stp_c.stp_reasonlate,
						stp_reasonlate_depart = stp_c.stp_reasonlate_depart,
						stp_description = stp_c.stp_description,
						stp_weightunit = stp_c.stp_weightunit,
						stp_countunit = stp_c.stp_countunit,
						stp_volumeunit = stp_c.stp_volumeunit,
						stp_lgh_mileage = stp_c.stp_lgh_mileage,
						stp_origschdt = stp_c.stp_origschdt,
						stp_region1 = stp_c.stp_region1,
						stp_region2 = stp_c.stp_region2,
						stp_region3 = stp_c.stp_region3,
						stp_region4 = stp_c.stp_region4,
						stp_reftype = stp_c.stp_reftype,
						stp_phonenumber = stp_c.stp_phonenumber,
						stp_delayhours = stp_c.stp_delayhours,
						stp_contact = stp_c.stp_contact,
						stp_activitystart_dt = stp_c.stp_activitystart_dt,
						stp_activityend_dt = stp_c.stp_activityend_dt,
						stp_eta = stp_c.stp_eta,
						stp_alloweddet = stp_c.stp_alloweddet,
						stp_lgh_mileage_mtid = stp_c.stp_lgh_mileage_mtid,
						stp_ord_mileage_mtid = stp_c.stp_ord_mileage_mtid,
						stp_ooa_mileage_mtid = stp_c.stp_ooa_mileage_mtid,
						
						--stp_ico_stp_number_child = CASE @lgh_outstatus_bottom_child
						--								WHEN 'CAN' THEN NULL
						--								--WHEN 'AVL' THEN NULL
						--								ELSE stops.stp_ico_stp_number_child
						--							END,
						skip_trigger = 1
				FROM	stops 
						INNER JOIN stops stp_c on stp_c.stp_number = stops.stp_ico_stp_number_child
				WHERE	stops.stp_number = @stp_number_parent


				--sync freightdetail

				IF @debug = 'Y' BEGIN
					print 'update existing freightdetail...'
				END

				UPDATE	freightdetail 
				SET		fgt_ordered_volume = fgt_c.fgt_ordered_volume,
						fgt_ordered_loadingmeters = fgt_c.fgt_ordered_loadingmeters,
						cmd_code = fgt_c.cmd_code,
						fgt_description = fgt_c.fgt_description,
						fgt_weight = fgt_c.fgt_weight,
						fgt_weightunit = fgt_c.fgt_weightunit,
						fgt_count = fgt_c.fgt_count,
						fgt_countunit = fgt_c.fgt_countunit,
						fgt_volumeunit = fgt_c.fgt_volumeunit,
						fgt_reftype = fgt_c.fgt_reftype,
						fgt_pallets_in = fgt_c.fgt_pallets_in,
						fgt_pallets_out = fgt_c.fgt_pallets_out,
						fgt_pallets_on_trailer = fgt_c.fgt_pallets_on_trailer,
						fgt_carryins1 = fgt_c.fgt_carryins1,
						fgt_carryins2 = fgt_c.fgt_carryins2,
						fgt_length = fgt_c.fgt_length,
						fgt_width = fgt_c.fgt_width,
						fgt_height = fgt_c.fgt_height,
						fgt_stackable = fgt_c.fgt_stackable,
						fgt_ordered_count = fgt_c.fgt_ordered_count,
						fgt_ordered_weight = fgt_c.fgt_ordered_weight,
						fgt_quantity_type = fgt_c.fgt_quantity_type,
						fgt_charge_type = fgt_c.fgt_charge_type,
						fgt_rate_type = fgt_c.fgt_rate_type,
						fgt_additionl_description = fgt_c.fgt_additionl_description,
						fgt_pallet_type = fgt_c.fgt_pallet_type,
						fgt_packageunit = fgt_c.fgt_packageunit,
						tank_loc = fgt_c.tank_loc,
						skip_trigger = 1
				FROM	freightdetail
						INNER JOIN stops stp_p on freightdetail.stp_number = stp_p.stp_number
						INNER JOIN stops stp_c on stp_p.stp_ico_stp_number_child = stp_c.stp_number
						INNER JOIN freightdetail fgt_c on stp_c.stp_number = fgt_c.stp_number
				WHERE	stp_p.stp_number = @stp_number_parent
						and freightdetail.fgt_sequence = fgt_c.fgt_sequence

				IF @debug = 'Y' BEGIN
					print 'deleting removed freightdetail...'
				END

				DELETE	freightdetail
				FROM	freightdetail
						INNER JOIN stops stp_p on freightdetail.stp_number = stp_p.stp_number
				WHERE	stp_p.stp_number = @stp_number_parent
						AND NOT EXISTS	(	SELECT	*
											FROM	freightdetail fgt_c_inner
											WHERE	fgt_c_inner.stp_number = stp_p.stp_ico_stp_number_child
													and fgt_c_inner.fgt_sequence = freightdetail.fgt_sequence
										)
				IF @debug = 'Y' BEGIN
					print 'adding new freightdetail...'
				END


				--Determine number of freightdetail to add (number of child not in parent)
				
				SELECT	@fgt_newcount = count(*)
				FROM	freightdetail fgt_c
						INNER JOIN stops stp_c on fgt_c.stp_number = stp_c.stp_number
						INNER JOIN stops stp_p on stp_p.stp_ico_stp_number_child = stp_c.stp_number
				WHERE	stp_p.stp_number = @stp_number_parent
						AND NOT EXISTS	(	SELECT	*
											FROM	freightdetail fgt_p_inner
											WHERE	fgt_p_inner.stp_number = stp_p.stp_number
													and fgt_p_inner.fgt_sequence = fgt_c.fgt_sequence
										)

				IF @debug = 'Y' BEGIN
					print 'number of new freightdetail to add...'
					print @fgt_newcount
				END
				
				IF @fgt_newcount > 0 BEGIN
				
					SELECT @fgt_sequence_next = MAX(fgt_p.fgt_sequence) + 1
					FROM	freightdetail fgt_p
							INNER JOIN stops stp_p on fgt_p.stp_number = stp_p.stp_number
					WHERE	stp_p.stp_number = @stp_number_parent

					IF @debug = 'Y' BEGIN
						select  'New parent freightdetail starting sequence @fgt_sequence_next', @fgt_sequence_next
					END
		
					EXEC @new_fgtnbr_start = dbo.getsystemnumberblock 'FGTNUM', NULL, @fgt_newcount
					--IF @@ERROR <> 0 GOTO ERROR_EXIT2
			
					SELECT @new_fgtnbr_next = @new_fgtnbr_start
					
					WHILE @new_fgtnbr_next < @new_fgtnbr_start + @fgt_newcount  BEGIN
						IF @debug = 'Y' BEGIN
							select  'Adding New parent freightdetail  sequence @new_fgtnbr_next', @new_fgtnbr_next, 'sequence', @fgt_sequence_next
						END

						INSERT	freightdetail	(
							fgt_number,
							stp_number, 
							fgt_sequence, 
							cmd_code, 
							fgt_description, 
							fgt_weight, 
							fgt_weightunit, 
							fgt_count, 
							fgt_countunit, 
							fgt_volumeunit, 
							fgt_reftype, 
							fgt_pallets_in, 
							fgt_pallets_out, 
							fgt_pallets_on_trailer, 
							fgt_carryins1, 
							fgt_carryins2, 
							fgt_length, 
							fgt_width, 
							fgt_height, 
							fgt_stackable, 
							fgt_ordered_count, 
							fgt_ordered_weight, 
							fgt_quantity_type, 
							fgt_charge_type, 
							fgt_rate_type, 
							fgt_additionl_description, 
							fgt_pallet_type, 
							fgt_packageunit, 
							tank_loc, 
							skip_trigger
						) 

						SELECT	@new_fgtnbr_next,
								stp_p.stp_number,
								@fgt_sequence_next,
								fgt_c.cmd_code,
								fgt_c.fgt_description,
								fgt_c.fgt_weight,
								fgt_c.fgt_weightunit,
								fgt_c.fgt_count,
								fgt_c.fgt_countunit,
								fgt_c.fgt_volumeunit,
								fgt_c.fgt_reftype,
								fgt_c.fgt_pallets_in, 
								fgt_c.fgt_pallets_out, 
								fgt_c.fgt_pallets_on_trailer, 
								fgt_c.fgt_carryins1, 
								fgt_c.fgt_carryins2, 
								fgt_c.fgt_length, 
								fgt_c.fgt_width, 
								fgt_c.fgt_height, 
								fgt_c.fgt_stackable, 
								fgt_c.fgt_ordered_count, 
								fgt_c.fgt_ordered_weight, 
								fgt_c.fgt_quantity_type, 
								fgt_c.fgt_charge_type, 
								fgt_c.fgt_rate_type, 
								fgt_c.fgt_additionl_description, 
								fgt_c.fgt_pallet_type, 
								fgt_c.fgt_packageunit, 
								fgt_c.tank_loc, 
								1
						FROM	stops stp_p
								INNER JOIN stops stp_c on stp_p.stp_ico_stp_number_child = stp_c.stp_number
								INNER JOIN freightdetail fgt_c on fgt_c.stp_number = stp_c.stp_number
						WHERE	stp_p.stp_number = @stp_number_parent
								and fgt_c.fgt_sequence = @fgt_sequence_next
						
						SELECT @new_fgtnbr_next = @new_fgtnbr_next + 1
						SELECT @fgt_sequence_next = @fgt_sequence_next + 1
					END

				END				
				
				SELECT	@stp_number_parent = MIN(stp_number) 
				FROM	@stopsupdate_parent
				WHERE	stp_number > @stp_number_parent
				

			END


			--update legheader stat
			IF @debug = 'Y' BEGIN
				print '--update legheader stat'
			END
		
			
				
			UPDATE	legheader
			SET		lgh_outstatus = CASE @lgh_outstatus_bottom_child
										WHEN 'CAN' THEN 'AVL'
										WHEN 'AVL' THEN 'PLN'
										ELSE ISNULL(lgh_c.lgh_outstatus, legheader.lgh_outstatus)
									END
			FROM	legheader
					INNER JOIN stops stp_p on stp_p.lgh_number = legheader.lgh_number
					INNER JOIN stops stp_c on stp_p.stp_ico_stp_number_child = stp_c.stp_number
					LEFT OUTER JOIN legheader lgh_c on lgh_c.lgh_number = stp_c.lgh_number
			WHERE	lgh_c.lgh_number = @lgh_number_child

			--update parent order, set to AVL if child cancels and disconnect ICO link
			IF @debug = 'Y' BEGIN
				print 'update parent order'
			END


			--PTS 58474 JJF 20111025
			--UPDATE	orderheader
			--SET		--ord_startdate = oh_c.ord_startdate,
			--		--ord_completiondate = oh_c.ord_completiondate,
			--		ord_startdate =	(	SELECT	MIN(stp_inner.stp_arrivaldate)
			--							FROM	stops stp_inner 
			--							WHERE	stp_inner.mov_number = orderheader.mov_number
			--									AND stp_inner.ord_hdrnumber = orderheader.ord_hdrnumber
			--									AND stp_type = 'PUP'
			--						),
			--		ord_completiondate =	(	SELECT	MAX(stp_inner.stp_departuredate)
			--									FROM	stops stp_inner 
			--									WHERE	stp_inner.mov_number = orderheader.mov_number
			--											AND stp_inner.ord_hdrnumber = orderheader.ord_hdrnumber
			--											AND stp_type = 'DRP'
			--								)--,
			--		ord_status =	CASE	@lgh_outstatus_bottom_child
			--								WHEN 'CAN' THEN 'AVL'
			--								WHEN 'AVL' THEN 'PLN'
			--								ELSE oh_c.ord_status
			--						END--,
			--		--PTS 58474 20110816									
			--		--ord_invoicestatus =		CASE  @lgh_outstatus_bottom_child
			--		--							WHEN 'CAN' THEN 'PND'
			--		--							ELSE oh_c.ord_invoicestatus
			--		--						END
			--		--end PTS 58474 20110816
			--FROM	orderheader 
			--		INNER JOIN legheader lgh_p on orderheader.mov_number = lgh_p.mov_number
			--		INNER JOIN stops stp_p on stp_p.lgh_number = lgh_p.lgh_number
			--		INNER JOIN stops stp_c on stp_p.stp_ico_stp_number_child = stp_c.stp_number
			--		LEFT OUTER JOIN legheader lgh_c on lgh_c.lgh_number = stp_c.lgh_number
			--		INNER JOIN orderheader oh_c on oh_c.mov_number = stp_c.mov_number
			--WHERE	stp_c.lgh_number = @lgh_number_child
			--		and stp_p.stp_ico_stp_number_child > 0

			--END PTS 58474 JJF 20111025
			
			----update parent paydetail to remove ico_lock when child cancelled
			--delete parent paydetail when child cancelled
			IF @debug = 'Y' BEGIN
				--print 'update parent paydetail to remove pyd_ico_ivd_number_child when child cancelled'
				print 'delete parent paydetail when child cancelled'
			END
			
			--UPDATE	paydetail	
			--SET		pyd_ico_ivd_number_child = null
			--FROM	paydetail
			--		INNER JOIN stops stp_p on paydetail.lgh_number = stp_p.lgh_number
			--		INNER JOIN stops stp_c on stp_p.stp_ico_stp_number_child = stp_c.stp_number
			--		LEFT OUTER JOIN legheader lgh_c on lgh_c.lgh_number = stp_c.lgh_number
			--WHERE	stp_c.lgh_number = @lgh_number_child
			--		and lgh_c.lgh_outstatus = NULL						

			DELETE	paydetail
			FROM	paydetail
					INNER JOIN stops stp_p on paydetail.lgh_number = stp_p.lgh_number
					INNER JOIN stops stp_c on stp_p.stp_ico_stp_number_child = stp_c.stp_number
					LEFT OUTER JOIN legheader lgh_c on lgh_c.lgh_number = stp_c.lgh_number
			WHERE	stp_c.lgh_number = @lgh_number_child
					--PTS 61053 JJF 20120508
					--and lgh_c.lgh_outstatus = NULL
					and ISNULL(lgh_c.lgh_outstatus, '') = ''
					--END PTS 61053 JJF 20120508

			--update child invoicedetal to remove ivd_ico_pyd_number_parent when child cancelled
			IF @debug = 'Y' BEGIN
				print 'update child invoicedetal to remove ivd_ico_pyd_number_parent when child cancelled'
			END

			UPDATE	invoicedetail	
			SET		ivd_ico_pyd_number_parent = NULL
			FROM	invoicedetail
					INNER JOIN stops stp_c on stp_c.ord_hdrnumber = invoicedetail.ord_hdrnumber
					LEFT OUTER JOIN legheader lgh_c on lgh_c.lgh_number = stp_c.lgh_number
			WHERE	stp_c.lgh_number = @lgh_number_child
					--PTS 61053 JJF 20120508
					--and lgh_c.lgh_outstatus = NULL
					and ISNULL(lgh_c.lgh_outstatus, '') = ''
					--END PTS 61053 JJF 20120508

			SELECT	@lgh_number_child = MIN(lgh_number)
			FROM	@legheaderupdate_child
			WHERE	lgh_number > @lgh_number_child

		END

		exec dbo.update_assetassignment @mov_number_parent
		
		exec dbo.update_audit @mov_number_parent

		exec dbo.update_move_light @mov_number_parent
		
		--PTS 58474 20110816
		exec update_ord  @mov_number_parent, 'CMP'				
		--end PTS 58474 20110816
		
		exec dbo.cleanup_asgns 
/*		
		--update child stops to remove ico locks when cancelled
		SELECT	@stp_number_parent = MIN(stp_number)
		FROM	@stopsupdate_parent
		
		WHILE (@stp_number_parent > 0) BEGIN
		
			UPDATE	stops
			SET		stp_ico_stp_number_parent = NULL,
					skip_trigger = 1
			FROM	stops
					INNER JOIN @stopsupdate_parent stp_p on stops.stp_number = stp_p.stp_ico_stp_number_child
					INNER JOIN orderheader oh_c on oh_c.mov_number = stops.mov_number
			WHERE	stp_p.stp_number = @stp_number_parent
					--and oh_c.ord_status in ('CAN', 'AVL')
					and oh_c.ord_status in ('CAN')
				
			SELECT	@stp_number_parent = MIN(stp_number) 
			FROM	@stopsupdate_parent
			WHERE	stp_number > @stp_number_parent
		END
*/

		SELECT	@lgh_number_child = MIN(lgh_number)
		FROM	@legheaderupdate_child

		WHILE (@lgh_number_child > 0) BEGIN

			--disconnect parent stops on cancel
			IF @debug = 'Y' BEGIN
				print 'disconnect parent stops on cancel'
			END

			UPDATE	stops
			SET		stp_ico_stp_number_child = NULL,
					skip_trigger = 1
			FROM	stops 
					INNER JOIN stops stp_c on stp_c.stp_ico_stp_number_parent = stops.stp_number
					LEFT OUTER JOIN legheader lgh_c on lgh_c.lgh_number = stp_c.lgh_number
			WHERE	stp_c.lgh_number = @lgh_number_child
					--PTS 61053 JJF 20120508
					--and lgh_c.lgh_outstatus = NULL
					and ISNULL(lgh_c.lgh_outstatus, '') = ''
					--END PTS 61053 JJF 20120508
	
			--disconnect child stops on cancel	
			IF @debug = 'Y' BEGIN
				print 'disconnect child stops on cancel	'
			END
			
			UPDATE	stops
			SET		stp_ico_stp_number_parent = NULL,
					skip_trigger = 1
			FROM	stops 
					INNER JOIN stops stp_p on stops.stp_ico_stp_number_parent = stp_p.stp_number
					LEFT OUTER JOIN legheader lgh_c on lgh_c.lgh_number = stops.lgh_number
			WHERE	stops.lgh_number = @lgh_number_child
					--PTS 61053 JJF 20120508
					--and lgh_c.lgh_outstatus = NULL
					and ISNULL(lgh_c.lgh_outstatus, '') = NULL
					--END PTS 61053 JJF 20120508

			SELECT	@lgh_number_child = MIN(lgh_number)
			FROM	@legheaderupdate_child
			WHERE	lgh_number > @lgh_number_child

		END
		
		IF @debug = 'Y' BEGIN
			select 'after changes...', @mov_number_parent mov_number_parent, @mov_number_child mov_number_child
			--EXEC intercompany_diagnostic @mov_number_parent, @mov_number_child
		END
	END	

END
GO
GRANT EXECUTE ON  [dbo].[intercompany_ico_sync_child_to_parent_sp] TO [public]
GO
