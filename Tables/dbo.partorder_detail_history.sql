CREATE TABLE [dbo].[partorder_detail_history]
(
[pod_hist_identity] [int] NOT NULL IDENTITY(1, 1),
[pod_group_identity] [int] NULL,
[pod_identity] [int] NOT NULL,
[poh_identity] [int] NOT NULL,
[pod_partnumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pod_description] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pod_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pod_originalcount] [int] NOT NULL,
[pod_originalcontainers] [int] NULL,
[pod_countpercontainer] [int] NULL,
[pod_adjustedcount] [int] NULL,
[pod_adjustedcontainers] [int] NULL,
[pod_pu_count] [int] NULL,
[pod_pu_containers] [int] NULL,
[pod_del_count] [int] NULL,
[pod_del_containers] [int] NULL,
[pod_cur_count] [int] NOT NULL,
[pod_cur_containers] [int] NOT NULL,
[pod_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pod_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pod_updatedon] [datetime] NULL,
[pod_release] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pod_sourcefile] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pod_originalweight] [float] NULL,
[pod_pu_weight] [float] NULL,
[pod_cur_weight] [float] NULL,
[pod_adjustedweight] [float] NULL,
[pod_weightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_pod_id_hist] ON [dbo].[partorder_detail_history] ([pod_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_pod_poh_id_hist] ON [dbo].[partorder_detail_history] ([poh_identity]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[partorder_detail_history] TO [public]
GO
GRANT INSERT ON  [dbo].[partorder_detail_history] TO [public]
GO
GRANT REFERENCES ON  [dbo].[partorder_detail_history] TO [public]
GO
GRANT SELECT ON  [dbo].[partorder_detail_history] TO [public]
GO
GRANT UPDATE ON  [dbo].[partorder_detail_history] TO [public]
GO
