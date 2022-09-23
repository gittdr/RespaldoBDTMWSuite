CREATE TABLE [dbo].[ImportErrorDefinition]
(
[ImportErrorDefinitionId] [int] NOT NULL IDENTITY(1, 1),
[MessageType] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MessageFormat] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ParameterCount] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportErrorDefinition] ADD CONSTRAINT [PK_ImportErrorDefinition] PRIMARY KEY CLUSTERED ([ImportErrorDefinitionId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ImportErrorDefinition_MessageType] ON [dbo].[ImportErrorDefinition] ([MessageType]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ImportErrorDefinition] TO [public]
GO
GRANT INSERT ON  [dbo].[ImportErrorDefinition] TO [public]
GO
GRANT SELECT ON  [dbo].[ImportErrorDefinition] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImportErrorDefinition] TO [public]
GO
