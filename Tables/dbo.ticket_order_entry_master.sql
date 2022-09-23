CREATE TABLE [dbo].[ticket_order_entry_master]
(
[ord_hdrnumber] [int] NOT NULL,
[toem_plan_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[toem_plan_status_override] [bit] NULL,
[toem_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toem_updatedate] [datetime] NULL,
[toem_update_reason] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toem_comments] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_ticket_order_entry_master] 
ON [dbo].[ticket_order_entry_master]
FOR INSERT, UPDATE 

AS 

SET NOCOUNT ON 

DECLARE @updatecount						int
DECLARE @delcount							int
DECLARE @currentdate						datetime 
DECLARE @valid								bit 
DECLARE @set_child_order_status				bit
DECLARE @tmwuser							varchar(255)
DECLARE @current_toem_plan_status			varchar(6)
DECLARE @new_toem_plan_status				varchar(6)
DECLARE @current_toem_plan_status_name		varchar(20)
DECLARE @new_toem_plan_status_name			varchar(20)
DECLARE @mst_ord_hdrnumber					int
DECLARE @mst_ord_number						varchar(12)
DECLARE @child_mov_number					int
DECLARE @reason								varchar(255)	
DECLARE @message							varchar(255)	
DECLARE	@child_order_status_from			varchar(6)
DECLARE @child_order_status_to				varchar(6)

SELECT	@updatecount = count(*) 
FROM	inserted

SELECT	@delcount = count(*)
FROM	deleted

SELECT	@currentdate = getdate()

--Validate status change
if update(toem_plan_status) BEGIN
	IF EXISTS (SELECT * 
				FROM inserted
				WHERE isnull(toem_plan_status_override, 0) = 0) BEGIN
		IF @updatecount > 1 BEGIN
			ROLLBACK TRAN
			RAISERROR (N'<MESSAGE>Only one order''s planning status may be updated at a time.</MESSAGE>', 16, 1)
			RETURN
		END

		SELECT	@mst_ord_number = rtrim(oh.ord_number),
				@mst_ord_hdrnumber = i.ord_hdrnumber
		FROM	orderheader oh INNER JOIN inserted i on oh.ord_hdrnumber = i.ord_hdrnumber
		
		
		SELECT @current_toem_plan_status = toem_plan_status
		FROM deleted
		
		SELECT @current_toem_plan_status = isnull(@current_toem_plan_status, 'PND')

		SELECT @new_toem_plan_status = toem_plan_status
		FROM inserted

		--PRINT '@current_toem_plan_status: ' + convert(varchar(6), @current_toem_plan_status)
		--PRINT '@new_toem_plan_status: ' + convert(varchar(6), @new_toem_plan_status)

		SELECT @valid = 1
		SELECT @reason = 'Cannot manually change to this status'
		IF @current_toem_plan_status = 'PND' BEGIN
			IF @new_toem_plan_status = 'STD' BEGIN
				SELECT @valid = 0
			END
			ELSE IF @new_toem_plan_status = 'CMP' BEGIN
				SELECT @valid = 0
			END
		END
		ELSE IF @current_toem_plan_status = 'CAN' BEGIN
			IF @new_toem_plan_status = 'STD' BEGIN
				SELECT @valid = 0
			END
			ELSE IF @new_toem_plan_status = 'CMP' BEGIN
				SELECT @valid = 0
			END
		END
		ELSE IF @current_toem_plan_status = 'STD' BEGIN
			IF @new_toem_plan_status = 'PND' BEGIN
				SELECT @valid = 0
			END
			IF @new_toem_plan_status = 'HLD' BEGIN
				--Set child orders on hold as well
				SELECT @set_child_order_status = 1
				SELECT @child_order_status_from = 'AVL'
				SELECT @child_order_status_to = 'HLD'

			END
			IF @new_toem_plan_status = 'CAN' or @new_toem_plan_status = '3RD' BEGIN
				--Allowed only if all child orders ord_status in ('AVL', 'CAN')
				IF EXISTS (SELECT *
										FROM orderheader oh 
											INNER JOIN ticket_order_entry_plan_orders toepo 
												on oh.ord_hdrnumber = toepo.ord_hdrnumber
											INNER JOIN ticket_order_entry_plan toep 
												on toepo.toep_id = toep.toep_id
										WHERE toep.ord_hdrnumber = @mst_ord_hdrnumber
												AND oh.ord_status not in ('AVL', 'CAN')) BEGIN
					SELECT @valid = 0
					SELECT @reason = 'All created orders must still be available or already cancelled.'
				END
				
	
				--If so, Set all child orders with ord_status = 'AVL' to 'CAN'
				IF @valid = 1 BEGIN
					SELECT @set_child_order_status = 1
					SELECT @child_order_status_from = 'AVL'
					SELECT @child_order_status_to = 'CAN'
				END

				
			END
			IF @new_toem_plan_status = 'CMP' BEGIN
				SELECT @valid = 0
			END
		END
		ELSE IF @current_toem_plan_status = 'HLD' BEGIN
			IF @new_toem_plan_status = 'PND' BEGIN
				--No child orders can exist
				IF EXISTS (SELECT *
										FROM orderheader oh 
											INNER JOIN ticket_order_entry_plan_orders toepo 
												on oh.ord_hdrnumber = toepo.ord_hdrnumber
											INNER JOIN ticket_order_entry_plan toep 
												on toepo.toep_id = toep.toep_id
										WHERE toep.ord_hdrnumber = @mst_ord_hdrnumber) BEGIN
					SELECT @valid = 0
					SELECT @reason = 'Created orders already exist.'
				END
			END
			IF @new_toem_plan_status = 'CAN' BEGIN
				--Allowed only if all child orders are not assigned
				IF EXISTS (	SELECT *
							FROM	assetassignment aa
									INNER JOIN legheader_active lgh 
										on aa.lgh_number = lgh.lgh_number
									INNER JOIN orderheader oh 
										on lgh.mov_number = oh.mov_number
									INNER JOIN ticket_order_entry_plan_orders toepo 
										on oh.ord_hdrnumber = toepo.ord_hdrnumber
									INNER JOIN ticket_order_entry_plan toep 
										on toepo.toep_id = toep.toep_id
							WHERE	toep.ord_hdrnumber = @mst_ord_hdrnumber) BEGIN
				

					SELECT @valid = 0
					SELECT @reason = 'Assigned orders exist.'
				END

				--If so, Set all child orders = 'HLD' to 'CAN'
				IF @valid = 1 BEGIN
					SELECT @set_child_order_status = 1
					SELECT @child_order_status_from = 'HLD'
					SELECT @child_order_status_to = 'CAN'
				END
				
			END
			IF @new_toem_plan_status = 'STD' BEGIN
				--Allowed only if orders have been created
				--Allowed only if orders ord_status in ('HLD', 'CMP')
				IF NOT EXISTS (SELECT *
										FROM orderheader oh 
											INNER JOIN ticket_order_entry_plan_orders toepo 
												on oh.ord_hdrnumber = toepo.ord_hdrnumber
											INNER JOIN ticket_order_entry_plan toep 
												on toepo.toep_id = toep.toep_id
										WHERE toep.ord_hdrnumber = @mst_ord_hdrnumber) BEGIN
					SELECT @valid = 0
					SELECT @reason = 'No orders have been created yet.'
				END
				ELSE IF EXISTS (SELECT *
										FROM orderheader oh 
											INNER JOIN ticket_order_entry_plan_orders toepo 
												on oh.ord_hdrnumber = toepo.ord_hdrnumber
											INNER JOIN ticket_order_entry_plan toep 
												on toepo.toep_id = toep.toep_id
										WHERE toep.ord_hdrnumber = @mst_ord_hdrnumber
												AND oh.ord_status not in ('HLD', 'CMP')) BEGIN
					SELECT @valid = 0
					SELECT @reason = 'Some orders must still be available.'
				END

				--If so, set child orders = 'HLD' to 'AVL'
				IF @valid = 1 BEGIN
					SELECT @set_child_order_status = 1
					SELECT @child_order_status_from = 'HLD'
					SELECT @child_order_status_to = 'AVL'
				END
				
			END
			IF @new_toem_plan_status = '3RD' BEGIN
				--Allowed if all child orders have ord_status in ('HLD', 'CAN')
				IF EXISTS (SELECT *
										FROM orderheader oh 
											INNER JOIN ticket_order_entry_plan_orders toepo 
												on oh.ord_hdrnumber = toepo.ord_hdrnumber
											INNER JOIN ticket_order_entry_plan toep 
												on toepo.toep_id = toep.toep_id
										WHERE toep.ord_hdrnumber = @mst_ord_hdrnumber
												AND oh.ord_status not in ('HLD', 'CAN')) BEGIN
					SELECT @valid = 0
					SELECT @reason = 'All created orders must still be on hold or already cancelled.'
				END

				--If so, Set all child orders with ord_status = 'HLD' to 'CAN'
				IF @valid = 1 BEGIN
					SELECT @set_child_order_status = 1
					SELECT @child_order_status_from = 'HLD'
					SELECT @child_order_status_to = 'CAN'
				END
			END
			IF @new_toem_plan_status = 'CMP' BEGIN
				SELECT @valid = 0
			END
		END
		ELSE IF @current_toem_plan_status = '3RD' BEGIN
			IF @new_toem_plan_status = 'STD' BEGIN
				SELECT @valid = 0
			END
			ELSE IF @new_toem_plan_status = 'CMP' BEGIN
				SELECT @valid = 0
			END
		END
		ELSE IF @current_toem_plan_status = 'CMP' BEGIN
			IF @new_toem_plan_status <> 'CMP' BEGIN
				SELECT @valid = 0
			END
		END


		--IF NOT VALID, return message
		IF @valid = 0 BEGIN
			SELECT	@current_toem_plan_status_name = name
			FROM	labelfile lbl
			WHERE	lbl.abbr = @current_toem_plan_status
					and lbl.labeldefinition = 'PlanMasterStatus'

			SELECT	@new_toem_plan_status_name = name
			FROM	labelfile lbl
			WHERE	lbl.abbr = @new_toem_plan_status
					and lbl.labeldefinition = 'PlanMasterStatus'


			SELECT @current_toem_plan_status_name = isnull(@current_toem_plan_status_name, @current_toem_plan_status)
			SELECT @new_toem_plan_status_name = isnull(@new_toem_plan_status_name, @new_toem_plan_status)

			ROLLBACK TRAN
			
			SELECT @message = N'<MESSAGE>Unable to change master planning status for order %s from %s to %s.' + CHAR(13) + CHAR(10) + 'Reason: %s</MESSAGE>'
			RAISERROR (@message, 16, 1, @mst_ord_number, @current_toem_plan_status_name, @new_toem_plan_status_name, @reason)
			RETURN
		END
		ELSE IF @set_child_order_status = 1 BEGIN 
			--Get list of orders to update

			SELECT	oh.mov_number as mov_number
			INTO	#childorders
			FROM	orderheader oh 
					INNER JOIN ticket_order_entry_plan_orders toepo 
						on oh.ord_hdrnumber = toepo.ord_hdrnumber
					INNER JOIN ticket_order_entry_plan toep 
						on toepo.toep_id = toep.toep_id
			WHERE toep.ord_hdrnumber = @mst_ord_hdrnumber
					AND oh.ord_status = @child_order_status_from

			SELECT	@child_mov_number = MIN(mov_number)
			FROM	#childorders
				
			--TODO Will need to adjust planning record counts as well	
			WHILE (@child_mov_number > 0) BEGIN
				IF @child_order_status_to = 'HLD' BEGIN
					--PRINT 'Setting ' + convert(varchar(12), @child_mov_number) + ' to HLD'
					exec Order_Status_Hold_sp @child_mov_number
				END
				ELSE IF @child_order_status_to = 'CAN' BEGIN
					--PRINT 'Setting ' + convert(varchar(12), @child_mov_number) + ' to CAN'
					exec Order_Status_Cancel_sp @child_mov_number

					UPDATE ticket_order_entry_plan
					SET toep_status = 'D'
					WHERE ord_hdrnumber = @mst_ord_hdrnumber
							and toep_status <> 'D'

				END
				ELSE IF @child_order_status_to = 'AVL' BEGIN
					--PRINT 'Setting ' + convert(varchar(12), @child_mov_number) + ' to AVL'
					exec Order_Status_Available_sp @child_mov_number

					--UPDATE ticket_order_entry_plan
					--SET toep_status =	CASE	WHEN toep_ordered_count = 0 THEN 'N'
					--							WHEN toep_ordered_count < toep_planned_count THEN 'P'
					--					END
					--WHERE ord_hdrnumber = @mst_ord_hdrnumber

				END
				
				
				SELECT	@child_mov_number = MIN(mov_number) 
				FROM	#childorders
				WHERE	mov_number > @child_mov_number
						

			END
		END


	END


END


EXEC gettmwuser @tmwuser output


IF (@updatecount > 0 and not update(toem_updateby) and not update(toem_updatedate)) OR
	(@updatecount > 0 and @delcount = 0) BEGIN
	UPDATE	ticket_order_entry_master
	SET		toem_updateby = @tmwuser,
			toem_updatedate = @currentdate
	FROM inserted
	WHERE inserted.ord_hdrnumber = ticket_order_entry_master.ord_hdrnumber
		and (isNull(ticket_order_entry_master.toem_updateby,'') <> @tmwuser
		OR isNull(ticket_order_entry_master.toem_updatedate, '19500101') <> getdate())
END

INSERT ticket_order_entry_master_audit(
			ord_hdrnumber,
			toema_plan_status,
			toema_plan_status_override,
			toema_updateby,
			toema_updatedate,
			toema_update_reason,
			toema_comments
		)
SELECT
		ord_hdrnumber,
		toem_plan_status,
		toem_plan_status_override,
		@tmwuser,
		@currentdate,
		toem_update_reason,
		toem_comments
FROM inserted

UPDATE ticket_order_entry_master
SET toem_plan_status_override = 0
FROM inserted
WHERE ticket_order_entry_master.ord_hdrnumber = inserted.ord_hdrnumber
		and inserted.toem_plan_status_override = 1


GO
ALTER TABLE [dbo].[ticket_order_entry_master] ADD CONSTRAINT [PK_ticket_order_entry_master] PRIMARY KEY CLUSTERED ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ticket_order_entry_master] TO [public]
GO
GRANT INSERT ON  [dbo].[ticket_order_entry_master] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ticket_order_entry_master] TO [public]
GO
GRANT SELECT ON  [dbo].[ticket_order_entry_master] TO [public]
GO
GRANT UPDATE ON  [dbo].[ticket_order_entry_master] TO [public]
GO
