CREATE TABLE [dbo].[dedbillingmetrics]
(
[dbm_id] [int] NOT NULL IDENTITY(1, 1),
[dbsd_id] [int] NOT NULL,
[dbse_id] [int] NOT NULL,
[dbs_id] [int] NULL,
[ord_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbm_amount] [decimal] (16, 4) NULL,
[dbm_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_date] [datetime] NULL,
[modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dedbillingmetrics] ADD CONSTRAINT [pk_dedbillingmetrics_dbm_id] PRIMARY KEY CLUSTERED ([dbm_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillingmetrics_dbm_type] ON [dbo].[dedbillingmetrics] ([dbm_type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillingmetrics_dbsd_id_dbse_id_dbs_id] ON [dbo].[dedbillingmetrics] ([dbsd_id], [dbse_id], [dbs_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillingmetrics_ord_billto] ON [dbo].[dedbillingmetrics] ([ord_billto]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dedbillingmetrics] TO [public]
GO
GRANT INSERT ON  [dbo].[dedbillingmetrics] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dedbillingmetrics] TO [public]
GO
GRANT SELECT ON  [dbo].[dedbillingmetrics] TO [public]
GO
GRANT UPDATE ON  [dbo].[dedbillingmetrics] TO [public]
GO
