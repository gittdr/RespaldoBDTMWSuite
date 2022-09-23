CREATE TABLE [dbo].[MobileCommMessageNodeProperty]
(
[PropertyContentId] [bigint] NOT NULL IDENTITY(1, 1),
[NodeContentId] [bigint] NOT NULL,
[PropertyDefinitionId] [int] NOT NULL,
[Value] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sequence] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageNodeProperty] ADD CONSTRAINT [PK_dbo_MobileCommMessageNodeProperty] PRIMARY KEY CLUSTERED ([PropertyContentId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_MobileCommMessageNodeProperty_NodeInstId_PropDefId] ON [dbo].[MobileCommMessageNodeProperty] ([NodeContentId], [PropertyDefinitionId]) INCLUDE ([Value]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_MobileCommMessageNodeProperty_PropDefId_NodeInstId] ON [dbo].[MobileCommMessageNodeProperty] ([PropertyDefinitionId], [NodeContentId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageNodeProperty] ADD CONSTRAINT [FK_MobileCommMessageNodeProperty_NodeContentId] FOREIGN KEY ([NodeContentId]) REFERENCES [dbo].[MobileCommMessageNode] ([NodeContentId]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MobileCommMessageNodeProperty] ADD CONSTRAINT [FK_MobileCommMessageNodeProperty_PropertyDefinitionId] FOREIGN KEY ([PropertyDefinitionId]) REFERENCES [dbo].[MobileCommMessageNodePropertyDefinition] ([PropertyDefinitionId])
GO
GRANT DELETE ON  [dbo].[MobileCommMessageNodeProperty] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommMessageNodeProperty] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommMessageNodeProperty] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommMessageNodeProperty] TO [public]
GO
