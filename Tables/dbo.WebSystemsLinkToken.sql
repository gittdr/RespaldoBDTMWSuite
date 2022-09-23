CREATE TABLE [dbo].[WebSystemsLinkToken]
(
[TokenID] [bigint] NOT NULL IDENTITY(1, 1),
[UserID] [bigint] NULL,
[Token] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Active] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[DeactivatedDate] [datetime] NULL,
[ttsUserId] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExpirationDate] [datetime] NOT NULL,
[SymmetricKey] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SymmetricIv] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WebSystemsLinkToken] ADD CONSTRAINT [PK_WebSystemsLinkToken] PRIMARY KEY CLUSTERED ([TokenID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_WebSystemsLinkToken_Token] ON [dbo].[WebSystemsLinkToken] ([Token]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WebSystemsLinkToken] ADD CONSTRAINT [FK_WebSystemsLinkToken_WebSystemsLinkCredentials] FOREIGN KEY ([UserID]) REFERENCES [dbo].[WebSystemsLinkCredentials] ([UserID])
GO
GRANT DELETE ON  [dbo].[WebSystemsLinkToken] TO [public]
GO
GRANT INSERT ON  [dbo].[WebSystemsLinkToken] TO [public]
GO
GRANT SELECT ON  [dbo].[WebSystemsLinkToken] TO [public]
GO
GRANT UPDATE ON  [dbo].[WebSystemsLinkToken] TO [public]
GO
