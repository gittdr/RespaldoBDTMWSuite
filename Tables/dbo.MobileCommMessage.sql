CREATE TABLE [dbo].[MobileCommMessage]
(
[MessageId] [bigint] NOT NULL IDENTITY(1, 1),
[ParentMessageId] [bigint] NULL,
[DirectionId] [int] NULL,
[MessageDefinitionId] [int] NULL,
[MessageGuid] [uniqueidentifier] NOT NULL,
[ExternalId] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MessageText] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorMessages] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetimeoffset] NOT NULL CONSTRAINT [df_MobileCommMessage_CreateDate] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessage] ADD CONSTRAINT [PK_MobileCommMessage] PRIMARY KEY CLUSTERED ([MessageId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_MobileCommMessage_CreatedDate] ON [dbo].[MobileCommMessage] ([CreatedDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ux_MobileCommMessage_ExternalId] ON [dbo].[MobileCommMessage] ([ExternalId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_MobileCommMessage_MessageGuid] ON [dbo].[MobileCommMessage] ([MessageGuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_MobileCommMessage_MessageId_MessageDefinitionId] ON [dbo].[MobileCommMessage] ([MessageId], [MessageDefinitionId]) INCLUDE ([ParentMessageId], [DirectionId], [ExternalId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_MobileCommMessage_ParentMessageId] ON [dbo].[MobileCommMessage] ([ParentMessageId], [MessageId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessage] ADD CONSTRAINT [FK_MobileCommMessage_DirectionId] FOREIGN KEY ([DirectionId]) REFERENCES [dbo].[MobileCommDirection] ([DirectionId])
GO
ALTER TABLE [dbo].[MobileCommMessage] ADD CONSTRAINT [FK_MobileCommMessage_MessageDefinitionId] FOREIGN KEY ([MessageDefinitionId]) REFERENCES [dbo].[MobileCommMessageDefinition] ([MessageDefinitionId])
GO
GRANT DELETE ON  [dbo].[MobileCommMessage] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommMessage] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommMessage] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommMessage] TO [public]
GO
