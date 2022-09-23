CREATE TABLE [dbo].[transf_pod_hist_notes]
(
[podhn_id] [int] NOT NULL IDENTITY(1, 1),
[podhn_notes] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[podh_id] [int] NULL,
[podhn_createdby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[podhn_createdon] [datetime] NULL,
[podhn_updatedby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[podhn_updatedon] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[transf_pod_hist_notes] ADD CONSTRAINT [PK_transf_pod_hist_notes] PRIMARY KEY CLUSTERED ([podhn_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[transf_pod_hist_notes] TO [public]
GO
GRANT INSERT ON  [dbo].[transf_pod_hist_notes] TO [public]
GO
GRANT SELECT ON  [dbo].[transf_pod_hist_notes] TO [public]
GO
GRANT UPDATE ON  [dbo].[transf_pod_hist_notes] TO [public]
GO
