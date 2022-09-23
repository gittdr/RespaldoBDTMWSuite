CREATE TABLE [dbo].[dedbillingschedule_tariffs]
(
[dbst_id] [int] NOT NULL IDENTITY(1, 1),
[dbs_id] [int] NOT NULL,
[dbse_id] [int] NOT NULL,
[tar_number] [int] NULL,
[trk_number] [int] NULL,
[dbst_rollinto_tar] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dedbillingschedule_tariffs] ADD CONSTRAINT [pk_dbst_id] PRIMARY KEY CLUSTERED ([dbst_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dedbillingschedule_tariffs] TO [public]
GO
GRANT INSERT ON  [dbo].[dedbillingschedule_tariffs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dedbillingschedule_tariffs] TO [public]
GO
GRANT SELECT ON  [dbo].[dedbillingschedule_tariffs] TO [public]
GO
GRANT UPDATE ON  [dbo].[dedbillingschedule_tariffs] TO [public]
GO
