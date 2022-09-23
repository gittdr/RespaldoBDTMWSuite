CREATE TABLE [dbo].[dedbillingscheduledetail]
(
[dbsd_id] [int] NOT NULL IDENTITY(1, 1),
[dbs_id] [int] NULL,
[dbsd_enddate] [datetime] NULL,
[created_date] [datetime] NULL,
[created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_date] [datetime] NULL,
[modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dedbillingscheduledetail] ADD CONSTRAINT [pk_dedbillingscheduledetail_dbsd_id] PRIMARY KEY CLUSTERED ([dbsd_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillingscheduledetail_dbs_id] ON [dbo].[dedbillingscheduledetail] ([dbs_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillingscheduledetail_dbsd_enddate] ON [dbo].[dedbillingscheduledetail] ([dbsd_enddate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dedbillingscheduledetail] TO [public]
GO
GRANT INSERT ON  [dbo].[dedbillingscheduledetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dedbillingscheduledetail] TO [public]
GO
GRANT SELECT ON  [dbo].[dedbillingscheduledetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[dedbillingscheduledetail] TO [public]
GO
