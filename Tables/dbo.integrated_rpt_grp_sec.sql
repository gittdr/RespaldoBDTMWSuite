CREATE TABLE [dbo].[integrated_rpt_grp_sec]
(
[ir_id] [int] NOT NULL,
[irgs_groupid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[integrated_rpt_grp_sec] ADD CONSTRAINT [pk_integrated_rpt_grp_sec] PRIMARY KEY CLUSTERED ([ir_id], [irgs_groupid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[integrated_rpt_grp_sec] ADD CONSTRAINT [fk_integrated_rpt_user_sec] FOREIGN KEY ([ir_id]) REFERENCES [dbo].[integratedreports] ([ir_id])
GO
GRANT DELETE ON  [dbo].[integrated_rpt_grp_sec] TO [public]
GO
GRANT INSERT ON  [dbo].[integrated_rpt_grp_sec] TO [public]
GO
GRANT REFERENCES ON  [dbo].[integrated_rpt_grp_sec] TO [public]
GO
GRANT SELECT ON  [dbo].[integrated_rpt_grp_sec] TO [public]
GO
GRANT UPDATE ON  [dbo].[integrated_rpt_grp_sec] TO [public]
GO
