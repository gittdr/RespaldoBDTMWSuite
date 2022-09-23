CREATE TABLE [dbo].[MobileCommMessageNodeDefinition]
(
[NodeDefinitionId] [int] NOT NULL IDENTITY(1, 1),
[MessageDefinitionId] [int] NOT NULL,
[ParentNodeDefinitionId] [int] NULL,
[Name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FriendlyName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Expression] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsArray] [bit] NOT NULL CONSTRAINT [DF__MobileCom__IsArr__0C82A893] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageNodeDefinition] ADD CONSTRAINT [PK_dbo_MobileCommMessageNodeDefinition] PRIMARY KEY CLUSTERED ([NodeDefinitionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_MobileCommMessageNodeDefinition_MessageDefId] ON [dbo].[MobileCommMessageNodeDefinition] ([MessageDefinitionId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageNodeDefinition] ADD CONSTRAINT [FK_MobileCommMessageNodeDefinition_MessageDefinitionId] FOREIGN KEY ([MessageDefinitionId]) REFERENCES [dbo].[MobileCommMessageDefinition] ([MessageDefinitionId]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MobileCommMessageNodeDefinition] ADD CONSTRAINT [FK_MobileCommMessageNodeDefinition_ParentNodeDefinitionId] FOREIGN KEY ([ParentNodeDefinitionId]) REFERENCES [dbo].[MobileCommMessageNodeDefinition] ([NodeDefinitionId])
GO
GRANT DELETE ON  [dbo].[MobileCommMessageNodeDefinition] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommMessageNodeDefinition] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommMessageNodeDefinition] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommMessageNodeDefinition] TO [public]
GO
