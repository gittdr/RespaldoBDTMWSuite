CREATE TABLE [dbo].[WebSystemsLinkLog]
(
[LogID] [bigint] NOT NULL IDENTITY(1, 1),
[UserID] [bigint] NULL,
[TokenID] [bigint] NULL,
[FunctionName] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Message] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogDateTime] [datetime] NULL,
[ttsUserId] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OperationId] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MessageType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogLevel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WebSystemsLinkLog] ADD CONSTRAINT [PK_WebSystemsLinkLog] PRIMARY KEY CLUSTERED ([LogID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_WebSystemsLinkLog_TokenId] ON [dbo].[WebSystemsLinkLog] ([TokenID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_WebSystemsLinkLog_UserId] ON [dbo].[WebSystemsLinkLog] ([UserID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WebSystemsLinkLog] ADD CONSTRAINT [FK_WebSystemsLinkLog_WebSystemsLinkCredentials] FOREIGN KEY ([UserID]) REFERENCES [dbo].[WebSystemsLinkCredentials] ([UserID])
GO
ALTER TABLE [dbo].[WebSystemsLinkLog] ADD CONSTRAINT [FK_WebSystemsLinkLog_WebSystemsLinkToken] FOREIGN KEY ([TokenID]) REFERENCES [dbo].[WebSystemsLinkToken] ([TokenID])
GO
GRANT DELETE ON  [dbo].[WebSystemsLinkLog] TO [public]
GO
GRANT INSERT ON  [dbo].[WebSystemsLinkLog] TO [public]
GO
GRANT SELECT ON  [dbo].[WebSystemsLinkLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[WebSystemsLinkLog] TO [public]
GO
