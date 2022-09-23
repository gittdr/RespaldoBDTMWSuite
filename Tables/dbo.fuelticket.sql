CREATE TABLE [dbo].[fuelticket]
(
[ftk_ticket_number] [int] NOT NULL,
[ftk_cty_start] [int] NOT NULL,
[ftk_cty_end] [int] NOT NULL,
[drv_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_hdrnumber] [int] NOT NULL,
[ftk_created_on] [datetime] NOT NULL CONSTRAINT [DF__fuelticke__ftk_c__4EC6A485] DEFAULT (getdate()),
[ftk_created_by] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__fuelticke__ftk_c__4FBAC8BE] DEFAULT (suser_sname()),
[ftk_updated_by] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ftk_liters] [decimal] (6, 2) NOT NULL,
[ftk_cost] [decimal] (8, 4) NULL,
[mov_number] [int] NULL,
[lgh_number] [int] NULL,
[ftk_printed_by] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ftk_printed_on] [datetime] NULL,
[ftk_reconciled_by] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ftk_reconciled_on] [datetime] NULL,
[ftk_canceled_by] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ftk_canceled_on] [datetime] NULL,
[ftk_invoice] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ftk_recycled] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__fuelticke__ftk_r__50AEECF7] DEFAULT ('N'),
[ftk_disper] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ftk_disper_on] [datetime] NULL,
[ftk_disper_by] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[au_fuelticket] ON [dbo].[fuelticket] AFTER UPDATE AS
	SET NOCOUNT ON

	DECLARE @updated_on DATETIME
	DECLARE @updated_by VARCHAR (128)

	SELECT @updated_on = current_timestamp, @updated_by = dbo.gettmwuser_fn()

	-- PTS 106605 - DJM - Add the deleted.lgh_number to the insert
	INSERT INTO fuelticket_updatelog (ftk_ticket_number, ftk_updated_on, ftk_updated_by, ftk_old_ord_hdrnumber, ftk_old_mov_number)
		SELECT deleted.ftk_ticket_number, @updated_on, @updated_by, deleted.ord_hdrnumber, deleted.mov_number
		FROM deleted

	IF UPDATE (ftk_printed_by)
	BEGIN
		INSERT INTO fuelticket_printlog
			SELECT inserted.ftk_ticket_number, @updated_on, inserted.ftk_printed_by
			FROM inserted
	END

GO
ALTER TABLE [dbo].[fuelticket] ADD CONSTRAINT [PK__fuelticket__4DD2804C] PRIMARY KEY CLUSTERED ([ftk_ticket_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ftk_mov_number] ON [dbo].[fuelticket] ([mov_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ftk_mov_lgh_number] ON [dbo].[fuelticket] ([mov_number], [lgh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[fuelticket] TO [public]
GO
GRANT INSERT ON  [dbo].[fuelticket] TO [public]
GO
GRANT SELECT ON  [dbo].[fuelticket] TO [public]
GO
GRANT UPDATE ON  [dbo].[fuelticket] TO [public]
GO
