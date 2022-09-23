CREATE TABLE [dbo].[dedbillingscheduleentity]
(
[dbse_id] [int] NOT NULL IDENTITY(1, 1),
[dbs_id] [int] NULL,
[ord_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_booked_revtype1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbse_use_selected_invoices] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbse_usedate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbse_priority] [int] NULL,
[dbse_override_output_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbse_action] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbse_emailflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbse_email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbse_printflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbse_printer] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbse_fileflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbse_filedirectory] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbse_printformattype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_id] [int] NULL,
[irk_id] [int] NULL,
[dbg_id_print] [int] NULL,
[dbg_id_aggregate] [int] NULL,
[created_date] [datetime] NULL,
[created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_date] [datetime] NULL,
[modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbse_cutoff_time] [datetime] NULL,
[dbse_applyall_rates] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_splitgroup] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_dedbillingscheduleentity] ON [dbo].[dedbillingscheduleentity]
FOR INSERT, UPDATE
AS

SET NOCOUNT ON

	IF UPDATE (dbse_cutoff_time)
	BEGIN 
		UPDATE dedbillingscheduleentity
		SET 	dbse_cutoff_time = '1900-01-01 00:00:00.000'
		FROM dedbillingscheduleentity ds
		JOIN inserted i 
		ON i.dbse_id = ds.dbse_id
		WHERE i.dbse_cutoff_time		is NULL
	END 


GO
ALTER TABLE [dbo].[dedbillingscheduleentity] ADD CONSTRAINT [pk_dedbillingscheduleentity_dbse_id] PRIMARY KEY CLUSTERED ([dbse_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillingscheduleentity_dbs_id] ON [dbo].[dedbillingscheduleentity] ([dbs_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillingscheduledetail_ord_billto] ON [dbo].[dedbillingscheduleentity] ([ord_billto]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dedbillingscheduleentity] TO [public]
GO
GRANT INSERT ON  [dbo].[dedbillingscheduleentity] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dedbillingscheduleentity] TO [public]
GO
GRANT SELECT ON  [dbo].[dedbillingscheduleentity] TO [public]
GO
GRANT UPDATE ON  [dbo].[dedbillingscheduleentity] TO [public]
GO
