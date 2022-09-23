CREATE TABLE [dbo].[expedite_audit_tbl]
(
[ord_hdrnumber] [int] NOT NULL,
[updated_by] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[activity] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updated_dt] [datetime] NOT NULL,
[update_note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mov_number] [int] NULL,
[lgh_number] [int] NULL,
[join_to_table_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[key_value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_number] [int] NULL,
[exp_idtype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exp_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expedite_audit_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[tg_auditonotes]
   ON  [dbo].[expedite_audit_tbl]
   AFTER insert
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

IF TRIGGER_NESTLEVEL() > 1
     RETURN


exec sp_auditanotasin
exec sp_auditanotaout

    -- Insert statements for trigger here

END
GO
ALTER TABLE [dbo].[expedite_audit_tbl] ADD CONSTRAINT [prkey_expedite_audit_tbl] PRIMARY KEY NONCLUSTERED ([expedite_audit_ident]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_expaud_key_value_activity] ON [dbo].[expedite_audit_tbl] ([activity], [key_value]) INCLUDE ([updated_by]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Activity_Note] ON [dbo].[expedite_audit_tbl] ([activity], [ord_hdrnumber], [update_note]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_exp_idtype_exp_id_updated_date] ON [dbo].[expedite_audit_tbl] ([exp_idtype], [exp_id], [updated_dt]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_join_key] ON [dbo].[expedite_audit_tbl] ([join_to_table_name], [key_value]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_expedite_audit_tbl_mov_number] ON [dbo].[expedite_audit_tbl] ([mov_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_orderactivity] ON [dbo].[expedite_audit_tbl] ([ord_hdrnumber], [activity]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [dk_expedite_audit_updated_dt] ON [dbo].[expedite_audit_tbl] ([updated_dt]) ON [PRIMARY]
GO
