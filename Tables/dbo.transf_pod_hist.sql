CREATE TABLE [dbo].[transf_pod_hist]
(
[podh_id] [int] NOT NULL IDENTITY(1, 1),
[poh_identity] [int] NULL,
[pod_identity] [int] NULL,
[pod_hist_identity] [int] NULL,
[podh_review_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[podh_revision] [int] NULL,
[podh_closedby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[podh_closedon] [datetime] NULL,
[podh_createdby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[podh_createdon] [datetime] NULL,
[podh_updatedby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[podh_updatedon] [datetime] NULL,
[pod_originalcount] [int] NULL,
[pod_originalcontainers] [int] NULL,
[pod_adjustedcount] [int] NULL,
[pod_adjustedcontainers] [int] NULL,
[pod_pu_count] [int] NULL,
[pod_pu_containers] [int] NULL,
[pod_cur_count] [int] NOT NULL,
[pod_cur_containers] [int] NOT NULL,
[pod_del_count] [int] NULL,
[pod_del_containers] [int] NULL,
[pod_updated_col] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pod_brn_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[transf_pod_hist] ADD CONSTRAINT [PK_transf_pod_hist] PRIMARY KEY CLUSTERED ([podh_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[transf_pod_hist] TO [public]
GO
GRANT INSERT ON  [dbo].[transf_pod_hist] TO [public]
GO
GRANT SELECT ON  [dbo].[transf_pod_hist] TO [public]
GO
GRANT UPDATE ON  [dbo].[transf_pod_hist] TO [public]
GO
