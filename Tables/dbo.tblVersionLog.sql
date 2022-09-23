CREATE TABLE [dbo].[tblVersionLog]
(
[Version] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrentDBVersion] [bit] NOT NULL,
[DtApplied] [datetime] NULL,
[Comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblVersionLog].[CurrentDBVersion]'
GO
GRANT DELETE ON  [dbo].[tblVersionLog] TO [public]
GO
GRANT INSERT ON  [dbo].[tblVersionLog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblVersionLog] TO [public]
GO
GRANT SELECT ON  [dbo].[tblVersionLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblVersionLog] TO [public]
GO
