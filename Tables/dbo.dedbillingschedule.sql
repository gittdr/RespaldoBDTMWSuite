CREATE TABLE [dbo].[dedbillingschedule]
(
[dbs_id] [int] NOT NULL IDENTITY(1, 1),
[dbs_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_action] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_emailflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_printflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_printer] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_fileflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_filedirectory] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_printformattype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_startdate] [datetime] NULL,
[dbs_endtype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_end_after] [int] NULL,
[dbs_end_by] [datetime] NULL,
[dbs_type_definition] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_daily_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_daily_days] [int] NULL,
[dbs_weekly_recur] [int] NULL,
[dbs_weekly_sunday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_weekly_monday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_weekly_tuesday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_weekly_wednesday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_weekly_thursday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_weekly_friday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_weekly_saturday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_monthly_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_monthly_daynumber] [int] NULL,
[dbs_monthly_occurrence] [int] NULL,
[dbs_monthly_week] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_monthly_dayofweek] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_id] [int] NULL,
[irk_id] [int] NULL,
[dbg_id_print] [int] NULL,
[dbg_id_aggregate] [int] NULL,
[dbs_use_selected_invoices] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_date] [datetime] NULL,
[modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_cutoff_time] [datetime] NULL,
[dbs_applyall_rates] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_dedbillingschedule] ON [dbo].[dedbillingschedule]
FOR INSERT, UPDATE
AS

	SET NOCOUNT ON
	
	IF UPDATE (dbs_cutoff_time)
	BEGIN 
		UPDATE dedbillingschedule
		SET 	dbs_cutoff_time = '1900-01-01 00:00:00.000'
		FROM dedbillingschedule ds
		JOIN inserted i 
		ON i.dbs_id = ds.dbs_id
		WHERE i.dbs_cutoff_time		is NULL
	END 


GO
ALTER TABLE [dbo].[dedbillingschedule] ADD CONSTRAINT [pk_dedbillingschedule_dbs_id] PRIMARY KEY CLUSTERED ([dbs_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dedbillingschedule] TO [public]
GO
GRANT INSERT ON  [dbo].[dedbillingschedule] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dedbillingschedule] TO [public]
GO
GRANT SELECT ON  [dbo].[dedbillingschedule] TO [public]
GO
GRANT UPDATE ON  [dbo].[dedbillingschedule] TO [public]
GO
