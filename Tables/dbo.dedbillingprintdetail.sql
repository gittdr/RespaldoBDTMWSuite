CREATE TABLE [dbo].[dedbillingprintdetail]
(
[dpd_id] [int] NOT NULL IDENTITY(1, 1),
[dbh_id] [int] NULL,
[dbg_id] [int] NULL,
[dbgt_id] [int] NULL,
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
[ivh_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[incomplete_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[create_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_date] [datetime] NULL,
[modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dedbillingprintdetail] ADD CONSTRAINT [pk_dedbillingprintdetail_dpd_id] PRIMARY KEY CLUSTERED ([dpd_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillingprintdetail_dbh_id] ON [dbo].[dedbillingprintdetail] ([dbh_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dedbillingprintdetail] TO [public]
GO
GRANT INSERT ON  [dbo].[dedbillingprintdetail] TO [public]
GO
GRANT SELECT ON  [dbo].[dedbillingprintdetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[dedbillingprintdetail] TO [public]
GO
