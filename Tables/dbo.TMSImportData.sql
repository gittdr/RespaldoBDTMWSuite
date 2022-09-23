CREATE TABLE [dbo].[TMSImportData]
(
[ImpDataId] [bigint] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ImportDate] [datetime] NOT NULL,
[ImportUser] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSImportData] ADD CONSTRAINT [PK_TMSImportData] PRIMARY KEY CLUSTERED ([ImpDataId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMSImportData] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSImportData] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSImportData] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSImportData] TO [public]
GO
