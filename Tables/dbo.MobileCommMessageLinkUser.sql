CREATE TABLE [dbo].[MobileCommMessageLinkUser]
(
[LinkUserId] [bigint] NOT NULL IDENTITY(1, 1),
[MessageId] [bigint] NOT NULL,
[usr_userid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageLinkUser] ADD CONSTRAINT [PK_MobileCommMessageLinkUser] PRIMARY KEY CLUSTERED ([LinkUserId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageLinkUser] ADD CONSTRAINT [FK_MobileCommMessageLinkUser_MobileCommMessageInstance_MessageId] FOREIGN KEY ([MessageId]) REFERENCES [dbo].[MobileCommMessage] ([MessageId]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MobileCommMessageLinkUser] ADD CONSTRAINT [FK_MobileCommMessageLinkUser_ttsusers_usr_userid] FOREIGN KEY ([usr_userid]) REFERENCES [dbo].[ttsusers] ([usr_userid]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[MobileCommMessageLinkUser] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommMessageLinkUser] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommMessageLinkUser] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommMessageLinkUser] TO [public]
GO
