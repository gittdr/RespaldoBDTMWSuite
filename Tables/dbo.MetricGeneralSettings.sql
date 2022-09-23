CREATE TABLE [dbo].[MetricGeneralSettings]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[SettingName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SettingValue] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricGeneralSettings] ADD CONSTRAINT [AutoPK_MetricGeneralSettings_SN] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricGeneralSettings] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricGeneralSettings] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricGeneralSettings] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricGeneralSettings] TO [public]
GO
