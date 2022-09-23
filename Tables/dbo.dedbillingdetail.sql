CREATE TABLE [dbo].[dedbillingdetail]
(
[dbd_id] [int] NOT NULL IDENTITY(1, 1),
[dbh_id] [int] NULL,
[ivh_hdrnumber] [int] NULL,
[created_date] [datetime] NULL,
[created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_date] [datetime] NULL,
[modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbd_retrieval_date] [datetime] NULL,
[ivh_definition] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbd_cmr_add] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dedbillingdetail] ADD CONSTRAINT [pk_dedbillingdetail_dbd_id] PRIMARY KEY CLUSTERED ([dbd_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillingdetail_dbh_id] ON [dbo].[dedbillingdetail] ([dbh_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillingdetail_ivh_hdrnumber] ON [dbo].[dedbillingdetail] ([ivh_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dedbillingdetail] TO [public]
GO
GRANT INSERT ON  [dbo].[dedbillingdetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dedbillingdetail] TO [public]
GO
GRANT SELECT ON  [dbo].[dedbillingdetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[dedbillingdetail] TO [public]
GO
