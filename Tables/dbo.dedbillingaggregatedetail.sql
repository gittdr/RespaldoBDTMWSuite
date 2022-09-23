CREATE TABLE [dbo].[dedbillingaggregatedetail]
(
[dbad_id] [int] NOT NULL IDENTITY(1, 1),
[dbh_id] [int] NULL,
[dbg_id] [int] NULL,
[dbgt_id] [int] NULL,
[dbsd_id] [int] NULL,
[dbgt_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbgt_description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbgt_sequence] [int] NULL,
[dbgt_supresszero] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbgt_subtotalonly] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbgd_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbgd_description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbgd_sequence] [int] NULL,
[ivd_quantity] [float] NULL,
[ivd_rate] [money] NULL,
[ivd_charge] [money] NULL,
[ivd_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_number] [int] NULL,
[ivh_hdrnumber] [int] NULL,
[dbhsd_use_selected_invoices] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbhsd_action] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbhsd_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_booked_revtype1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[create_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_date] [datetime] NULL,
[modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_number] [int] NULL,
[tar_tariffnumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_tariffitem] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dedbillingaggregatedetail] ADD CONSTRAINT [pk_dedbillingaggregatedetail_dbad_id] PRIMARY KEY CLUSTERED ([dbad_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillingaggregatedetail_dbh_id] ON [dbo].[dedbillingaggregatedetail] ([dbh_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dedbillingaggregatedetail] TO [public]
GO
GRANT INSERT ON  [dbo].[dedbillingaggregatedetail] TO [public]
GO
GRANT SELECT ON  [dbo].[dedbillingaggregatedetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[dedbillingaggregatedetail] TO [public]
GO
