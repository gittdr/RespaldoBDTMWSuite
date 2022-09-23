CREATE TABLE [dbo].[WebSystemsLinkCredentials]
(
[UserID] [bigint] NOT NULL IDENTITY(1, 1),
[UserName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Password] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternalLoginID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[CreatedApplication] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedDate] [datetime] NULL,
[UpdatedApplication] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllowCreate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_WebSystemsLinkCredentials_AllowCreate] DEFAULT ('N'),
[CredentialMarker] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WebSystemsLinkCredentials] ADD CONSTRAINT [PK_WebSystemsLinkCredentials] PRIMARY KEY CLUSTERED ([UserID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_WebSystemsLinkCredentials_UserName] ON [dbo].[WebSystemsLinkCredentials] ([UserName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WebSystemsLinkCredentials] TO [public]
GO
GRANT INSERT ON  [dbo].[WebSystemsLinkCredentials] TO [public]
GO
GRANT SELECT ON  [dbo].[WebSystemsLinkCredentials] TO [public]
GO
GRANT UPDATE ON  [dbo].[WebSystemsLinkCredentials] TO [public]
GO
