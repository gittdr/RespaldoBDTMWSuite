CREATE TABLE [dbo].[MobileCommMessageNode]
(
[NodeContentId] [bigint] NOT NULL IDENTITY(1, 1),
[MessageId] [bigint] NOT NULL,
[NodeDefinitionId] [int] NOT NULL,
[ParentNodeContentId] [bigint] NULL,
[ChildContentId] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageNode] ADD CONSTRAINT [PK_dbo_MobileCommMessageNode] PRIMARY KEY CLUSTERED ([NodeContentId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_MobileCommMessageNode_MessageId_NodeContentId] ON [dbo].[MobileCommMessageNode] ([MessageId], [NodeContentId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageNode] ADD CONSTRAINT [FK_MobileCommMessageNode_ChildContentId] FOREIGN KEY ([ChildContentId]) REFERENCES [dbo].[MobileCommMessage] ([MessageId])
GO
ALTER TABLE [dbo].[MobileCommMessageNode] ADD CONSTRAINT [FK_MobileCommMessageNode_MessageId] FOREIGN KEY ([MessageId]) REFERENCES [dbo].[MobileCommMessage] ([MessageId]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MobileCommMessageNode] ADD CONSTRAINT [FK_MobileCommMessageNode_NodeDefinitionId] FOREIGN KEY ([NodeDefinitionId]) REFERENCES [dbo].[MobileCommMessageNodeDefinition] ([NodeDefinitionId])
GO
ALTER TABLE [dbo].[MobileCommMessageNode] ADD CONSTRAINT [FK_MobileCommMessageNode_ParentNodeContentId] FOREIGN KEY ([ParentNodeContentId]) REFERENCES [dbo].[MobileCommMessageNode] ([NodeContentId])
GO
GRANT DELETE ON  [dbo].[MobileCommMessageNode] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommMessageNode] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommMessageNode] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommMessageNode] TO [public]
GO
