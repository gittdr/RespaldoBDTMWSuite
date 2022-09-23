CREATE TABLE [dbo].[WebSystemsLinkMobileUserCredentials]
(
[MobileUserId] [int] NOT NULL IDENTITY(1, 1),
[UserName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HasMobileAccess] [bit] NOT NULL,
[HasPay] [bit] NOT NULL,
[CreatedDate] [datetime] NULL,
[UpdatedDate] [datetime] NULL,
[TimeStamp] [timestamp] NULL,
[TtsUserId] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaxPerDay] [money] NULL,
[MaxPerTransaction] [money] NULL,
[MaxPercentOfTrip] [money] NULL,
[MaxPerTrip] [money] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WebSystemsLinkMobileUserCredentials] ADD CONSTRAINT [PK__WebSyste__3F8FBFA4C02F99D9] PRIMARY KEY CLUSTERED ([MobileUserId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_WebSystemsLinkMobileUserCredentialsTtsUserId] ON [dbo].[WebSystemsLinkMobileUserCredentials] ([TtsUserId]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[WebSystemsLinkMobileUserCredentials] TO [public]
GO
GRANT SELECT ON  [dbo].[WebSystemsLinkMobileUserCredentials] TO [public]
GO
GRANT UPDATE ON  [dbo].[WebSystemsLinkMobileUserCredentials] TO [public]
GO
