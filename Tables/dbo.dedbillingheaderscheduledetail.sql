CREATE TABLE [dbo].[dedbillingheaderscheduledetail]
(
[dbh_id] [int] NOT NULL,
[dbsd_id] [int] NOT NULL,
[dbse_id] [int] NOT NULL,
[dbs_id] [int] NULL,
[dbhsd_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbhsd_action] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbhsd_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbhsd_usedate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbhsd_use_selected_invoices] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbhsd_enddate] [datetime] NULL,
[dbg_id_aggregate] [int] NULL,
[ord_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_booked_revtype1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_date] [datetime] NULL,
[modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbhsd_applyall_rates] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dedbillingheaderscheduledetail] ADD CONSTRAINT [pk_dedbillingheaderscheduledetail_dbh_id_dbsd_id] PRIMARY KEY CLUSTERED ([dbh_id], [dbsd_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillingheaderscheduledetail_dbs_id] ON [dbo].[dedbillingheaderscheduledetail] ([dbs_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillingheaderscheduledetail_dbsd_id] ON [dbo].[dedbillingheaderscheduledetail] ([dbsd_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillingheaderscheduledetail_dbse_id] ON [dbo].[dedbillingheaderscheduledetail] ([dbse_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dedbillingheaderscheduledetail] TO [public]
GO
GRANT INSERT ON  [dbo].[dedbillingheaderscheduledetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dedbillingheaderscheduledetail] TO [public]
GO
GRANT SELECT ON  [dbo].[dedbillingheaderscheduledetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[dedbillingheaderscheduledetail] TO [public]
GO
