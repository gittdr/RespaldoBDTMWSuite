CREATE TABLE [dbo].[MessageParticipants]
(
[Id] [bigint] NOT NULL IDENTITY(1, 1),
[ConversationId] [int] NOT NULL,
[UserId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageParticipants] ADD CONSTRAINT [PK_MessageParticipants] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageParticipants] ADD CONSTRAINT [FK_MessageParticipants_MessageConversations] FOREIGN KEY ([ConversationId]) REFERENCES [dbo].[MessageConversations] ([Id])
GO
ALTER TABLE [dbo].[MessageParticipants] ADD CONSTRAINT [FK_MessageParticipants_MessageUsers] FOREIGN KEY ([UserId]) REFERENCES [dbo].[MessageUsers] ([Id])
GO
GRANT DELETE ON  [dbo].[MessageParticipants] TO [public]
GO
GRANT INSERT ON  [dbo].[MessageParticipants] TO [public]
GO
GRANT SELECT ON  [dbo].[MessageParticipants] TO [public]
GO
GRANT UPDATE ON  [dbo].[MessageParticipants] TO [public]
GO
