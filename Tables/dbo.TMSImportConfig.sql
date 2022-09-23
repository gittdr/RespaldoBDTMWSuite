CREATE TABLE [dbo].[TMSImportConfig]
(
[ImpId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ImportType] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [dc_TMSImportConfig_CreateDate] DEFAULT (getdate()),
[CreateUser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dc_TMSImportConfig_CreateUser] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSImportConfig] ADD CONSTRAINT [PK_TMSImportConfig] PRIMARY KEY CLUSTERED ([ImpId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UI_TMSImportConfig_Name] ON [dbo].[TMSImportConfig] ([Name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMSImportConfig] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSImportConfig] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSImportConfig] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSImportConfig] TO [public]
GO
