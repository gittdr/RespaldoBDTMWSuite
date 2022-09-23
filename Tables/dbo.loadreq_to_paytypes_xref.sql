CREATE TABLE [dbo].[loadreq_to_paytypes_xref]
(
[lrp_identity] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NOT NULL,
[mov_number] [int] NOT NULL,
[ca_id] [int] NULL,
[tsr_stl_rate_tar_number] [int] NULL,
[lrq_equip_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lrq_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lrp_sequence] [int] NOT NULL,
[lrp_max_amt] [money] NULL,
[lrp_bid_amt] [money] NULL,
[lrp_checked] [int] NOT NULL,
[lrp_itemsection] [int] NOT NULL,
[lrp_standardset] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_date] [datetime] NULL,
[modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ca_id] ON [dbo].[loadreq_to_paytypes_xref] ([ca_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pk_lrp_identity] ON [dbo].[loadreq_to_paytypes_xref] ([lrp_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_mov_number] ON [dbo].[loadreq_to_paytypes_xref] ([mov_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ord_hdrnumber] ON [dbo].[loadreq_to_paytypes_xref] ([ord_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tsr_stl_rate_tar_number] ON [dbo].[loadreq_to_paytypes_xref] ([tsr_stl_rate_tar_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[loadreq_to_paytypes_xref] TO [public]
GO
GRANT INSERT ON  [dbo].[loadreq_to_paytypes_xref] TO [public]
GO
GRANT REFERENCES ON  [dbo].[loadreq_to_paytypes_xref] TO [public]
GO
GRANT SELECT ON  [dbo].[loadreq_to_paytypes_xref] TO [public]
GO
GRANT UPDATE ON  [dbo].[loadreq_to_paytypes_xref] TO [public]
GO
