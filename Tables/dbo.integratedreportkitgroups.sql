CREATE TABLE [dbo].[integratedreportkitgroups]
(
[irk_id] [int] NOT NULL,
[grp_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[integratedreportkitgroups] ADD CONSTRAINT [pk_integratedreportkitgroups] PRIMARY KEY CLUSTERED ([irk_id], [grp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[integratedreportkitgroups] TO [public]
GO
GRANT INSERT ON  [dbo].[integratedreportkitgroups] TO [public]
GO
GRANT SELECT ON  [dbo].[integratedreportkitgroups] TO [public]
GO
GRANT UPDATE ON  [dbo].[integratedreportkitgroups] TO [public]
GO
