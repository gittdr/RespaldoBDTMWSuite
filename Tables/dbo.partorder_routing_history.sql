CREATE TABLE [dbo].[partorder_routing_history]
(
[por_hist_identity] [int] NOT NULL IDENTITY(1, 1),
[por_group_identity] [int] NULL,
[por_identity] [int] NOT NULL,
[poh_identity] [int] NOT NULL,
[por_master_ordhdr] [int] NULL,
[por_ordhdr] [int] NULL,
[por_origin] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[por_begindate] [datetime] NULL,
[por_destination] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[por_enddate] [datetime] NULL,
[por_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[por_updatedon] [datetime] NULL,
[por_route] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[por_trl_unload_dt] [datetime] NULL,
[por_sequence] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_por_id_hist] ON [dbo].[partorder_routing_history] ([por_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_por_mstord_hist] ON [dbo].[partorder_routing_history] ([por_master_ordhdr]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_por_ord_hist] ON [dbo].[partorder_routing_history] ([por_ordhdr]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[partorder_routing_history] TO [public]
GO
GRANT INSERT ON  [dbo].[partorder_routing_history] TO [public]
GO
GRANT REFERENCES ON  [dbo].[partorder_routing_history] TO [public]
GO
GRANT SELECT ON  [dbo].[partorder_routing_history] TO [public]
GO
GRANT UPDATE ON  [dbo].[partorder_routing_history] TO [public]
GO
