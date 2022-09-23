CREATE TABLE [dbo].[dedbillingheader]
(
[dbh_id] [int] NOT NULL IDENTITY(1, 1),
[ivh_hdrnumber] [int] NULL,
[ivh_invoicenumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbs_id_createbill] [int] NULL,
[dbsd_id_createbill] [int] NULL,
[dbse_id_createbill] [int] NULL,
[dbsd_enddate_createbill] [datetime] NULL,
[ord_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_booked_revtype1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbh_override_output_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbh_emailflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbh_email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbh_printflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbh_printer] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbh_fileflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbh_filedirectory] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbh_printformattype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_id] [int] NULL,
[irk_id] [int] NULL,
[created_date] [datetime] NULL,
[created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_date] [datetime] NULL,
[modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbh_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbh_custinvnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_splitgroup] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dedbillingheader] ADD CONSTRAINT [pk_dedbillingheader_dbh_id] PRIMARY KEY CLUSTERED ([dbh_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillingheader_dbs_id_createbill] ON [dbo].[dedbillingheader] ([dbs_id_createbill]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillingheader_dbsd_id_createbill] ON [dbo].[dedbillingheader] ([dbsd_id_createbill]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillingheader_dbse_id_createbill] ON [dbo].[dedbillingheader] ([dbse_id_createbill]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillingheader_ivh_hdrnumber] ON [dbo].[dedbillingheader] ([ivh_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillingheader_ord_billto] ON [dbo].[dedbillingheader] ([ord_billto]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dedbillingheader] TO [public]
GO
GRANT INSERT ON  [dbo].[dedbillingheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dedbillingheader] TO [public]
GO
GRANT SELECT ON  [dbo].[dedbillingheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[dedbillingheader] TO [public]
GO
