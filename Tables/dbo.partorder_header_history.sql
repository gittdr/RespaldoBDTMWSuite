CREATE TABLE [dbo].[partorder_header_history]
(
[poh_hist_identity] [int] NOT NULL IDENTITY(1, 1),
[poh_group_identity] [int] NOT NULL,
[poh_identity] [int] NOT NULL,
[poh_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[poh_supplier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[poh_plant] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[poh_dock] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_jittime] [int] NULL,
[poh_sequence] [int] NULL,
[poh_reftype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[poh_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[poh_datereceived] [datetime] NOT NULL,
[poh_pickupdate] [datetime] NULL,
[poh_deliverdate] [datetime] NULL,
[poh_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_updatedon] [datetime] NULL,
[poh_comment] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_release] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[poh_scanned] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_timelineid] [int] NULL,
[poh_tlmod_reason] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_supplieralias] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_xdock_event] [varchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_poh_branch_hist] ON [dbo].[partorder_header_history] ([poh_branch], [poh_supplier]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_poh_del_hist] ON [dbo].[partorder_header_history] ([poh_deliverdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_poh_id_hist] ON [dbo].[partorder_header_history] ([poh_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_poh_pu_hist] ON [dbo].[partorder_header_history] ([poh_pickupdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_poh_refnum_hist] ON [dbo].[partorder_header_history] ([poh_refnum]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_poh_supplier_hist] ON [dbo].[partorder_header_history] ([poh_supplier]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[partorder_header_history] TO [public]
GO
GRANT INSERT ON  [dbo].[partorder_header_history] TO [public]
GO
GRANT REFERENCES ON  [dbo].[partorder_header_history] TO [public]
GO
GRANT SELECT ON  [dbo].[partorder_header_history] TO [public]
GO
GRANT UPDATE ON  [dbo].[partorder_header_history] TO [public]
GO
