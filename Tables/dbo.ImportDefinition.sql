CREATE TABLE [dbo].[ImportDefinition]
(
[ImportDefinitionId] [int] NOT NULL IDENTITY(1, 1),
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StoreRawFile] [bit] NOT NULL,
[VerboseLogging] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportDefinition] ADD CONSTRAINT [PK_ImportDefinition] PRIMARY KEY CLUSTERED ([ImportDefinitionId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ImportDefinition] TO [public]
GO
GRANT INSERT ON  [dbo].[ImportDefinition] TO [public]
GO
GRANT SELECT ON  [dbo].[ImportDefinition] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImportDefinition] TO [public]
GO
