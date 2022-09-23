CREATE TABLE [dbo].[UserScreenConfigurationUsers]
(
[UserID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserScreenConfigurationID] [bigint] NOT NULL,
[IsDefault] [bit] NOT NULL CONSTRAINT [DF_UserScreenConfigurationUsers_IsDefault_1] DEFAULT ((0)),
[IsGroup] [bit] NOT NULL CONSTRAINT [DF_UserScreenConfigurationUsers_IsGroup_1] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserScreenConfigurationUsers] ADD CONSTRAINT [PK_UserScreenConfigurationUsers] PRIMARY KEY CLUSTERED ([UserID], [IsGroup], [UserScreenConfigurationID]) ON [PRIMARY]
GO
