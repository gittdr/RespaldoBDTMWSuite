CREATE TABLE [dbo].[TMWConfigSetting]
(
[SettingId] [int] NOT NULL IDENTITY(1, 1),
[AppKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SectionKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItemKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SettingDescription] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Value] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Username] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanningView] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_TMWConfigSetting_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMWConfigSetting] ADD CONSTRAINT [PK_TMWConfigSetting_SettingId] PRIMARY KEY CLUSTERED ([SettingId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMWConfigSetting] ADD CONSTRAINT [UC_TMWConfigSetting_AppKey_SectionKey_ItemKey_Domain_DomainValue] UNIQUE NONCLUSTERED ([AppKey], [SectionKey], [ItemKey], [LOB], [PlanningView], [Username]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMWConfigSetting] ADD CONSTRAINT [FK_TMWConfigSetting_TMWConfigItem] FOREIGN KEY ([AppKey], [SectionKey], [ItemKey]) REFERENCES [dbo].[TMWConfigItem] ([AppKey], [SectionKey], [ItemKey])
GO
GRANT DELETE ON  [dbo].[TMWConfigSetting] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWConfigSetting] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWConfigSetting] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWConfigSetting] TO [public]
GO
