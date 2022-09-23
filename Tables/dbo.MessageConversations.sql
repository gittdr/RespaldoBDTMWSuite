CREATE TABLE [dbo].[MessageConversations]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[DetailTypeId] [smallint] NOT NULL,
[DetailId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateStarted] [smalldatetime] NOT NULL,
[DateArchived] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageConversations] ADD CONSTRAINT [PK_MessageConversations] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageConversations] ADD CONSTRAINT [FK_MessageConversations_MessageDetailTypes] FOREIGN KEY ([DetailTypeId]) REFERENCES [dbo].[MessageDetailTypes] ([Id])
GO
GRANT DELETE ON  [dbo].[MessageConversations] TO [public]
GO
GRANT INSERT ON  [dbo].[MessageConversations] TO [public]
GO
GRANT SELECT ON  [dbo].[MessageConversations] TO [public]
GO
GRANT UPDATE ON  [dbo].[MessageConversations] TO [public]
GO
