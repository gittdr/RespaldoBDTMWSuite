CREATE TABLE [dbo].[ticket_order_entry_plan]
(
[toep_id] [int] NOT NULL,
[toep_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_hdrnumber] [int] NOT NULL,
[toep_delivery_date] [datetime] NOT NULL,
[toep_ordered_count] [int] NOT NULL,
[toep_planned_count] [int] NOT NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[toep_shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[toep_driver] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[toep_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[toep_trailer] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toep_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toep_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toep_trailer2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toep_bookedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toep_delete_reason_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toep_delete_reason_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toep_deletedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toep_deleteddate] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toep_createdate] [datetime] NULL,
[toep_lastupdatedate] [datetime] NULL,
[toep_lastupdateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toep_tarnumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toep_rate] [money] NULL,
[toep_ordered_weight] [float] NULL,
[toep_planned_weight] [float] NULL,
[toep_weight_per_load] [float] NULL,
[toep_weights_units] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toep_invoicestatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toep_paystatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toep_work_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toep_ordered_work_quantity] [float] NULL,
[toep_planned_work_quantity] [float] NULL,
[toep_work_quantity_per_load] [float] NULL,
[toep_origin_earliestdate] [datetime] NULL,
[toep_origin_latestdate] [datetime] NULL,
[toep_dest_earliestdate] [datetime] NULL,
[toep_dest_latestdate] [datetime] NULL,
[toep_ord_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toep_ord_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toep_ord_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toep_ord_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toep_trl_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toep_consignee] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_ticket_order_entry_plan] on [dbo].[ticket_order_entry_plan] for insert
as
			
	DECLARE @tmwuser varchar (255)
	exec gettmwuser @tmwuser output  

	update	ticket_order_entry_plan
	   set	toep_bookedby = @tmwuser,
		--PTS 35684
            toep_createdate = getdate()
		--END PTS 35684
	  from	inserted
	 where	inserted.toep_id = ticket_order_entry_plan.toep_id



GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

	CREATE TRIGGER [dbo].[iut_ticket_order_entry_plan] 
		ON [dbo].[ticket_order_entry_plan] 
		FOR INSERT, UPDATE

	AS	
		SET NOCOUNT ON
		--PTS84590 MBR 01/16/15
		IF NOT EXISTS (SELECT TOP 1 * FROM inserted)
			RETURN

		DECLARE @PlanMasterAutoComplete varchar(1)

		SELECT	@PlanMasterAutoComplete = left(gi_string1, 1)
		FROM	generalinfo
		WHERE	gi_name = 'PlanMasterAutoComplete'

		--Maintain Master Plan status
		IF UPDATE(toep_status) BEGIN

			UPDATE	ticket_order_entry_master
			SET		ord_hdrnumber = i.ord_hdrnumber,
					toem_plan_status = 'STD',
					toem_plan_status_override = 1,
					toem_comments = 'Planning record status set to New or In Progress.  Primary status updated to Started.'
			FROM	inserted i
					INNER JOIN ticket_order_entry_master toem 
						on i.ord_hdrnumber = toem.ord_hdrnumber
			WHERE	i.toep_status in ('N', 'P')
					AND toem_plan_status <> 'STD'


			INSERT	ticket_order_entry_master(
						ord_hdrnumber,
						toem_plan_status,
						toem_plan_status_override,
						toem_comments
					)
			SELECT	i.ord_hdrnumber, 
					'STD',
					1,
					'Planning record status set to New or In Progress.  Primary status added and set to Started.'
			FROM	inserted i
			WHERE	NOT EXISTS(SELECT	* 
								FROM	inserted i
										INNER JOIN ticket_order_entry_master toem 
											on i.ord_hdrnumber = toem.ord_hdrnumber)
					AND i.toep_status in ('N', 'P')

			IF @PlanMasterAutoComplete = 'Y' BEGIN
				UPDATE	ticket_order_entry_master
				SET		ord_hdrnumber = i.ord_hdrnumber,
						toem_plan_status = 'CMP',
						toem_plan_status_override = 1,
						toem_comments = 'Planning record status set to Complete and no New or In Progress Plans exist.  Primary status updated to Complete.'
				FROM	inserted i
						INNER JOIN ticket_order_entry_master toem 
							on i.ord_hdrnumber = toem.ord_hdrnumber
				WHERE	i.toep_status in ('C')
						AND NOT EXISTS(SELECT * 
										FROM ticket_order_entry_plan toeminner
										WHERE toeminner.ord_hdrnumber = i.ord_hdrnumber
											AND toeminner.toep_id <> i.toep_id
											AND toeminner.toep_status in ('N', 'P'))
						AND toem_plan_status <> 'CMP'

						


				INSERT	ticket_order_entry_master(
							ord_hdrnumber,
							toem_plan_status,
							toem_plan_status_override,
							toem_comments
						)
				SELECT	i.ord_hdrnumber, 
						'CMP',
						1,
						'Planning record status set to Complete and no New or In Progress Plans exist.  Primary status added and set to Complete.'
				FROM	inserted i
				WHERE	NOT EXISTS(SELECT	* 
									FROM	inserted i
											INNER JOIN ticket_order_entry_master toem 
												on i.ord_hdrnumber = toem.ord_hdrnumber)
						AND i.toep_status in ('C')
						AND NOT EXISTS(SELECT * 
										FROM ticket_order_entry_plan toeminner
										WHERE toeminner.ord_hdrnumber = i.ord_hdrnumber
											AND toeminner.toep_id <> i.toep_id
											AND toeminner.toep_status in ('N', 'P'))


				UPDATE	ticket_order_entry_master
				SET		ord_hdrnumber = i.ord_hdrnumber,
						toem_plan_status = 'CMP',
						toem_plan_status_override = 1,
						toem_comments = 'Planning record status set to Deleted and no New or In Progress Plans exist and remaining planning records are completed.  Primary status updated to Complete.'
				FROM	inserted i
						INNER JOIN ticket_order_entry_master toem 
							on i.ord_hdrnumber = toem.ord_hdrnumber
				WHERE	i.toep_status = 'D'
						AND NOT EXISTS(SELECT * 
										FROM ticket_order_entry_plan toeminner
										WHERE toeminner.ord_hdrnumber = i.ord_hdrnumber
											AND toeminner.toep_id <> i.toep_id
											AND toeminner.toep_status in ('N', 'P'))
						AND EXISTS(SELECT * 
										FROM ticket_order_entry_plan toeminner
										WHERE toeminner.ord_hdrnumber = i.ord_hdrnumber
											AND toeminner.toep_id <> i.toep_id
											AND toeminner.toep_status in ('C'))
						AND toem_plan_status <> 'CMP'
						


				INSERT	ticket_order_entry_master(
							ord_hdrnumber,
							toem_plan_status,
							toem_plan_status_override,
							toem_comments
						)
				SELECT	i.ord_hdrnumber, 
						'CMP',
						1,
						'Planning record status set to Deleted and no New or In Progress Plans exist and remaining planning records are completed.  Primary status added and set to Complete.'
				FROM	inserted i
				WHERE	NOT EXISTS(SELECT	* 
									FROM	inserted i
											INNER JOIN ticket_order_entry_master toem 
												on i.ord_hdrnumber = toem.ord_hdrnumber)
						AND i.toep_status = 'D'
						AND NOT EXISTS(SELECT * 
										FROM ticket_order_entry_plan toeminner
										WHERE toeminner.ord_hdrnumber = i.ord_hdrnumber
											AND toeminner.toep_id <> i.toep_id
											AND toeminner.toep_status in ('N', 'P'))
						AND EXISTS(SELECT * 
										FROM ticket_order_entry_plan toeminner
										WHERE toeminner.ord_hdrnumber = i.ord_hdrnumber
											AND toeminner.toep_id <> i.toep_id
											AND toeminner.toep_status in ('C'))
			END


			UPDATE	ticket_order_entry_master
			SET		ord_hdrnumber = i.ord_hdrnumber,
					toem_plan_status = 'CAN',
					toem_plan_status_override = 1,
					toem_comments = 'Planning record status set to Deleted and no other New, In Progress or Completed Plans exist.  Primary status updated to Cancelled.'
			FROM	inserted i
					INNER JOIN ticket_order_entry_master toem 
						on i.ord_hdrnumber = toem.ord_hdrnumber
			WHERE	i.toep_status = 'D'
					AND NOT EXISTS(SELECT * 
									FROM ticket_order_entry_plan toeminner
									WHERE toeminner.ord_hdrnumber = i.ord_hdrnumber
										AND toeminner.toep_id <> i.toep_id
										AND toeminner.toep_status in ('N', 'P', 'C'))
					AND toem_plan_status <> 'CAN'
					


			INSERT	ticket_order_entry_master(
						ord_hdrnumber,
						toem_plan_status,
						toem_plan_status_override,
						toem_comments
					)
			SELECT	i.ord_hdrnumber, 
					'CAN',
					1,
					'Planning record status set to Deleted and no other New, In Progress or Completed Plans exist.  Primary status added and set to Cancelled.'
			FROM	inserted i
			WHERE	NOT EXISTS(SELECT	* 
								FROM	inserted i
										INNER JOIN ticket_order_entry_master toem 
											on i.ord_hdrnumber = toem.ord_hdrnumber)
					AND i.toep_status = 'D'
					AND NOT EXISTS(SELECT * 
									FROM ticket_order_entry_plan toeminner
									WHERE toeminner.ord_hdrnumber = i.ord_hdrnumber
										AND toeminner.toep_id <> i.toep_id
										AND toeminner.toep_status in ('N', 'P', 'C'))

		END
		
	


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

	CREATE TRIGGER [dbo].[ut_ticket_order_entry_plan] 
	ON [dbo].[ticket_order_entry_plan] 
	FOR UPDATE
	AS	

	--PTS 30289 JJF 1/12/06
	DECLARE @RecStatus	char(1)
	DECLARE @tmwuser 	varchar (255)
	
	--PTS 43039 SGB 06/06/08 
	SET NOCOUNT ON
	--END PTS 43039 SGB 06/06/08 
	
	--PTS84590 MBR 01/16/15
	IF NOT EXISTS (SELECT TOP 1 * FROM inserted) 
		RETURN

	--PTS 35684
	EXEC gettmwuser @tmwuser output
	--END PTS 35684

	IF UPDATE(toep_planned_count) OR UPDATE(toep_ordered_count)
		BEGIN
				UPDATE	ticket_order_entry_plan
				   SET	toep_status = 'C'
	 			  FROM	inserted
				 WHERE	 inserted.toep_id = ticket_order_entry_plan.toep_id AND
					inserted.toep_ordered_count = inserted.toep_planned_count AND
					ticket_order_entry_plan.toep_status <> 'C'

				--PTS 46118 JJF 20090702
				UPDATE	ticket_order_entry_plan
				   SET	toep_status = 'P'
	 			  FROM	inserted
				 WHERE	 inserted.toep_id = ticket_order_entry_plan.toep_id AND
					inserted.toep_planned_count > 0 AND
					inserted.toep_planned_count < inserted.toep_ordered_count AND
					ticket_order_entry_plan.toep_status <> 'P'
				--END PTS 46118 JJF 20090702
		END
	--PTS 30289 JJF 1/12/06
	IF UPDATE(toep_status) BEGIN
		SELECT 	@RecStatus = toep_status
		FROM 	inserted
		IF @RecStatus = 'D' BEGIN
			--PTS 35684
			--EXEC gettmwuser @tmwuser output
			--END PTS 35684

			UPDATE	ticket_order_entry_plan
			SET	toep_deletedby = @tmwuser,
				toep_deleteddate = GETDATE()
			FROM	inserted
			WHERE	inserted.toep_id = ticket_order_entry_plan.toep_id 
		END	
	END

	--PTS 35684
	update ticket_order_entry_plan
	   set toep_lastupdateby = 	@tmwuser,
		   toep_lastupdatedate = getdate()
	  from	inserted
	 where	inserted.toep_id = ticket_order_entry_plan.toep_id
	--END PTS 35684


GO
ALTER TABLE [dbo].[ticket_order_entry_plan] ADD CONSTRAINT [PK__ticket_order_ent__68A2479C] PRIMARY KEY CLUSTERED ([toep_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ordhdr_deldate_dk] ON [dbo].[ticket_order_entry_plan] ([ord_hdrnumber], [toep_delivery_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ticket_order_entry_plan] TO [public]
GO
GRANT INSERT ON  [dbo].[ticket_order_entry_plan] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ticket_order_entry_plan] TO [public]
GO
GRANT SELECT ON  [dbo].[ticket_order_entry_plan] TO [public]
GO
GRANT UPDATE ON  [dbo].[ticket_order_entry_plan] TO [public]
GO
