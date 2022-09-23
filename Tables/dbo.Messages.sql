CREATE TABLE [dbo].[Messages]
(
[Id] [bigint] NOT NULL IDENTITY(1, 1),
[ConversationId] [int] NOT NULL,
[FromUserId] [int] NOT NULL,
[Message] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateSent] [smalldatetime] NOT NULL,
[DateReceived] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Messages] ADD CONSTRAINT [PK_Messages] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Messages] ADD CONSTRAINT [FK_Messages_MessageConversations] FOREIGN KEY ([ConversationId]) REFERENCES [dbo].[MessageConversations] ([Id])
GO
ALTER TABLE [dbo].[Messages] ADD CONSTRAINT [FK_Messages_MessageUsers] FOREIGN KEY ([FromUserId]) REFERENCES [dbo].[MessageUsers] ([Id])
GO
GRANT DELETE ON  [dbo].[Messages] TO [public]
GO
GRANT INSERT ON  [dbo].[Messages] TO [public]
GO
GRANT SELECT ON  [dbo].[Messages] TO [public]
GO
GRANT UPDATE ON  [dbo].[Messages] TO [public]
GO
