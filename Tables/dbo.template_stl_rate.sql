CREATE TABLE [dbo].[template_stl_rate]
(
[tsr_number] [int] NOT NULL,
[tsr_template_tar_number] [int] NOT NULL,
[tsr_template_trk_number] [int] NOT NULL,
[tsr_stl_rate_trk_number] [int] NOT NULL,
[tsr_stl_rate_tar_number] [int] NOT NULL,
[tsr_order_ord_number] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tsr_order_ord_hdrnumber] [int] NULL,
[tsr_order_mov_number] [int] NULL,
[tsr_master_ord_number] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tsr_master_ord_hdrnumber] [int] NULL,
[tsr_createby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tsr_createdate] [datetime] NULL,
[last_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_MASTER_ord_hdrnumber] ON [dbo].[template_stl_rate] ([tsr_master_ord_hdrnumber]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_tsr_number] ON [dbo].[template_stl_rate] ([tsr_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tar_number] ON [dbo].[template_stl_rate] ([tsr_template_tar_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_trk_number] ON [dbo].[template_stl_rate] ([tsr_template_trk_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[template_stl_rate] TO [public]
GO
GRANT INSERT ON  [dbo].[template_stl_rate] TO [public]
GO
GRANT REFERENCES ON  [dbo].[template_stl_rate] TO [public]
GO
GRANT SELECT ON  [dbo].[template_stl_rate] TO [public]
GO
GRANT UPDATE ON  [dbo].[template_stl_rate] TO [public]
GO
