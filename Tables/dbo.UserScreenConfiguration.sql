CREATE TABLE [dbo].[UserScreenConfiguration]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[object] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[user_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[xmlconfiguration] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[modifiedby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[modifieddate] [datetime] NOT NULL CONSTRAINT [DF_userdcreen_modifieddate] DEFAULT (getdate()),
[isGroup] [bit] NOT NULL CONSTRAINT [isGroupValue] DEFAULT (0),
[isDefault] [bit] NOT NULL CONSTRAINT [isDefaultValue] DEFAULT (0),
[UserScreenConfigurationName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsLocation] [bit] NOT NULL CONSTRAINT [isLocationDefaultValue] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserScreenConfiguration] ADD CONSTRAINT [pk_id_user_isGroup_isLocation] PRIMARY KEY CLUSTERED ([id], [user_id], [isGroup], [IsLocation]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UserScreenConfiguration] TO [public]
GO
GRANT INSERT ON  [dbo].[UserScreenConfiguration] TO [public]
GO
GRANT REFERENCES ON  [dbo].[UserScreenConfiguration] TO [public]
GO
GRANT SELECT ON  [dbo].[UserScreenConfiguration] TO [public]
GO
GRANT UPDATE ON  [dbo].[UserScreenConfiguration] TO [public]
GO
