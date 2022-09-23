CREATE TABLE [dbo].[tblLinks]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[SourceFormSN] [int] NULL,
[TargetFormSN] [int] NULL,
[MCSN] [int] NULL,
[Status] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCData] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateModified] [datetime] NULL,
[LinkID] [int] NULL,
[Version] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblLinks] ADD CONSTRAINT [Link_Primary_Key_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblLinks] TO [public]
GO
GRANT INSERT ON  [dbo].[tblLinks] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblLinks] TO [public]
GO
GRANT SELECT ON  [dbo].[tblLinks] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblLinks] TO [public]
GO
