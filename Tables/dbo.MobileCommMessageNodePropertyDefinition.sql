CREATE TABLE [dbo].[MobileCommMessageNodePropertyDefinition]
(
[PropertyDefinitionId] [int] NOT NULL IDENTITY(1, 1),
[NodeDefinitionId] [int] NOT NULL,
[Name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DatatypeId] [int] NOT NULL,
[FriendlyName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Expression] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageNodePropertyDefinition] ADD CONSTRAINT [PK_dbo_MobileCommMessageNodePropertyDefinition] PRIMARY KEY CLUSTERED ([PropertyDefinitionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_MobileCommMessageNodePropertyDefinition_NodeDefinitionIdName] ON [dbo].[MobileCommMessageNodePropertyDefinition] ([NodeDefinitionId], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageNodePropertyDefinition] ADD CONSTRAINT [FK_MobileCommMessageNodePropertyDefinition_DatatypeId] FOREIGN KEY ([DatatypeId]) REFERENCES [dbo].[MobileCommDataType] ([DatatypeId])
GO
ALTER TABLE [dbo].[MobileCommMessageNodePropertyDefinition] ADD CONSTRAINT [FK_MobileCommMessageNodePropertyDefinition_NodeDefinitionId] FOREIGN KEY ([NodeDefinitionId]) REFERENCES [dbo].[MobileCommMessageNodeDefinition] ([NodeDefinitionId]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[MobileCommMessageNodePropertyDefinition] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommMessageNodePropertyDefinition] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommMessageNodePropertyDefinition] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommMessageNodePropertyDefinition] TO [public]
GO
