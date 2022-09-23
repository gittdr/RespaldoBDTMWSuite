SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Order_Replan_sp]
		(@p_mov_number	int) 
AS

/**
 * 
 * NAME:
 * Order_Replan_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *
 * RETURNS: 
 *
 * RESULT SETS: 
 *
 * PARAMETERS:
 * @p_mov_number	int		Mov number
 *
 *
 * REVISION HISTORY:
 * 10/12/2005.01 ? PTS30121 - Jon Fallon ? Created Procedure
 * 12/1/2005.01 - PTS 30770 JJF update toep status 
 *
 **/

	DECLARE @err int
	DECLARE @toep_id int
	--DECLARE @ord_hdrnumber int
	--DECLARE @lgh_number int

	--PTS 47858 JJF 20090716
	DECLARE @ord_work_quantity float
	--END PTS 47858 JJF 20090716

	SELECT   @toep_id = toepo.toep_id,
			--PTS 47858 JJF 20090716
			@ord_work_quantity = 
				CASE (SELECT TOP 1 lbl.labeldefinition
									FROM	labelfile lbl
									WHERE	lbl.labeldefinition in (	'FlatUnits',
																		'CountUnits', 
																		'WeightUnits', 
																		'VolumeUnits'
																	)
											and	IsNull(lbl.retired, 'N') <> 'Y'
											and lbl.abbr = toep.toep_work_unit)
					WHEN 'CountUnits' THEN
						ISNULL(oh.ord_totalpieces, 0)
					WHEN 'WeightUnits' THEN
						ISNULL(oh.ord_totalweight, 0)
					WHEN 'VolumeUnits' THEN
						ISNULL(oh.ord_totalvolume, 0)
					ELSE
						0
				END

			--END PTS 47858 JJF 20090716
			
	FROM	ticket_order_entry_plan toep 
			INNER JOIN ticket_order_entry_plan_orders toepo ON toep.toep_id = toepo.toep_id
			INNER JOIN orderheader oh ON toepo.ord_hdrnumber = oh.ord_hdrnumber
	WHERE    (oh.mov_number = @p_mov_number)
	
	BEGIN TRAN  
	
	SELECT @err = 0
	
	IF @toep_id IS NOT NULL BEGIN  --If order originated from a ticket planning order
		
		--12/1/2005.01 - PTS 30770 JJF update toep status 
		UPDATE   ticket_order_entry_plan
		SET            toep_planned_count = toep_planned_count - 1, 
						--PTS 43800 JJF 20081024
						--PTS 47858 JJF 20090716
						--toep_planned_weight = toep_planned_weight - isnull(toep_weight_per_load, 0),
						toep_planned_work_quantity = toep_planned_work_quantity - @ord_work_quantity,
						--PTS 43800 JJF 20081024
				toep_status = 'N '
		WHERE    (toep_id = @toep_id)
		
		SELECT @err = @@Error
		IF @err = 0 BEGIN
			exec Order_Status_Cancel_sp @p_mov_number
			SELECT @err = @@Error
		END
		
	END
	ELSE BEGIN  --Otherwise, just remove the assets from the trip
		UPDATE event   
		SET skip_trigger = 1,  
			evt_carrier = 'UNKNOWN',   
			evt_driver1 = 'UNKNOWN',   
			evt_driver2 = 'UNKNOWN',   
			evt_tractor = 'UNKNOWN',   
			evt_trailer1 = 'UNKNOWN',   
			evt_trailer2 = 'UNKNOWN'
		WHERE evt_mov_number = @p_mov_number 
		SELECT @err = @@Error

		WHILE ((	SELECT COUNT(*)   
				FROM	STOPS  
				WHERE	mov_number = @p_mov_number AND  
						stp_lgh_status <> 'AVL') > 0) and (@err = 0) BEGIN  
		
			UPDATE stops  
			SET skip_trigger = 1,   
				stp_lgh_status = 'AVL'   
			WHERE mov_number = @p_mov_number AND  
					stp_number = (SELECT MIN(stp_number)   
									FROM   stops  
									WHERE  mov_number = @p_mov_number AND  
											stp_lgh_status <> 'AVL')  
			SELECT @err = @@Error
		END  

		IF @err = 0 BEGIN
			UPDATE orderheader
			SET ord_status = 'AVL'
			WHERE mov_number = @p_mov_number
			SELECT @err = @@Error
		END
		
		IF @err = 0 BEGIN
			UPDATE legheader 
			SET lgh_outstatus = 'AVL' 
			WHERE mov_number = @p_mov_number
			SELECT @err = @@Error
		END
		
		IF @err = 0 BEGIN
			exec update_assetassignment @p_mov_number
			SELECT @err = @@Error
		END
		
		IF @err = 0 BEGIN
			exec update_move_light @p_mov_number
			SELECT @err = @@Error
		END
	END

	IF @err = 0 BEGIN
		COMMIT TRAN
		RETURN 0
	END
	ELSE BEGIN
		ROLLBACK TRAN
		RETURN 1
	END
GO
GRANT EXECUTE ON  [dbo].[Order_Replan_sp] TO [public]
GO
