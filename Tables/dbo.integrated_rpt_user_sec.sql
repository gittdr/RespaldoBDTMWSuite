CREATE TABLE [dbo].[integrated_rpt_user_sec]
(
[ir_id] [int] NOT NULL,
[irus_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[integrated_rpt_user_sec] ADD CONSTRAINT [pk_integrated_rpt_user_secc] PRIMARY KEY CLUSTERED ([ir_id], [irus_userid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[integrated_rpt_user_sec] TO [public]
GO
GRANT INSERT ON  [dbo].[integrated_rpt_user_sec] TO [public]
GO
GRANT REFERENCES ON  [dbo].[integrated_rpt_user_sec] TO [public]
GO
GRANT SELECT ON  [dbo].[integrated_rpt_user_sec] TO [public]
GO
GRANT UPDATE ON  [dbo].[integrated_rpt_user_sec] TO [public]
GO
