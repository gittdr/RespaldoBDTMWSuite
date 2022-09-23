CREATE TABLE [dbo].[WatchDogGeneralSettings]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[ins_date] [datetime] NULL CONSTRAINT [DF__WatchDogG__ins_d__29585610] DEFAULT (getdate()),
[upd_date] [datetime] NULL CONSTRAINT [DF__WatchDogG__upd_d__2A4C7A49] DEFAULT (getdate()),
[SettingName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SettingValue] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WatchDogGeneralSettings] TO [public]
GO
GRANT INSERT ON  [dbo].[WatchDogGeneralSettings] TO [public]
GO
GRANT SELECT ON  [dbo].[WatchDogGeneralSettings] TO [public]
GO
GRANT UPDATE ON  [dbo].[WatchDogGeneralSettings] TO [public]
GO
