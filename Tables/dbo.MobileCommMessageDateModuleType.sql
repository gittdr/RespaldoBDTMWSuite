CREATE TABLE [dbo].[MobileCommMessageDateModuleType]
(
[ModuleId] [int] NOT NULL,
[ModuleName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageDateModuleType] ADD CONSTRAINT [PK_MobileCommMessageDateModuleType] PRIMARY KEY CLUSTERED ([ModuleId]) ON [PRIMARY]
GO
