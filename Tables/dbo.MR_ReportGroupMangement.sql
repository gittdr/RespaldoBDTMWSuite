CREATE TABLE [dbo].[MR_ReportGroupMangement]
(
[rptgrpmang_user] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rptgrpmang_group] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MR_ReportGroupMangement] ADD CONSTRAINT [PK__MR_Repor__BEB5E5201703279F] PRIMARY KEY CLUSTERED ([rptgrpmang_user], [rptgrpmang_group]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MR_ReportGroupMangement] TO [public]
GO
GRANT INSERT ON  [dbo].[MR_ReportGroupMangement] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MR_ReportGroupMangement] TO [public]
GO
GRANT SELECT ON  [dbo].[MR_ReportGroupMangement] TO [public]
GO
GRANT UPDATE ON  [dbo].[MR_ReportGroupMangement] TO [public]
GO
