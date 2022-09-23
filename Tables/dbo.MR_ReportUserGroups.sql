CREATE TABLE [dbo].[MR_ReportUserGroups]
(
[MR_group] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MR_groupid] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MR_ReportUserGroups] ADD CONSTRAINT [PK__MR_Repor__7494D8BED8E4D13A] PRIMARY KEY CLUSTERED ([MR_group]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MR_ReportUserGroups] TO [public]
GO
GRANT INSERT ON  [dbo].[MR_ReportUserGroups] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MR_ReportUserGroups] TO [public]
GO
GRANT SELECT ON  [dbo].[MR_ReportUserGroups] TO [public]
GO
GRANT UPDATE ON  [dbo].[MR_ReportUserGroups] TO [public]
GO
