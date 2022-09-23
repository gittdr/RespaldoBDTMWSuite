CREATE TABLE [dbo].[core_Setting]
(
[SettingID] [int] NOT NULL IDENTITY(1, 1),
[GroupName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__core_Sett__Group__3D18292E] DEFAULT (''),
[SettingsClassTypeName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PropertyName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SerializedValue] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Created] [datetime] NOT NULL CONSTRAINT [DF__core_Sett__Creat__3E0C4D67] DEFAULT (getdate()),
[Updated] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[core_Setting] ADD CONSTRAINT [PK_core_Setting] PRIMARY KEY CLUSTERED ([SettingID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[core_Setting] TO [public]
GO
GRANT INSERT ON  [dbo].[core_Setting] TO [public]
GO
GRANT REFERENCES ON  [dbo].[core_Setting] TO [public]
GO
GRANT SELECT ON  [dbo].[core_Setting] TO [public]
GO
GRANT UPDATE ON  [dbo].[core_Setting] TO [public]
GO
