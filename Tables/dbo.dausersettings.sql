CREATE TABLE [dbo].[dausersettings]
(
[dau_id] [int] NOT NULL IDENTITY(1, 1),
[dau_userid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dau_startdate] [datetime] NULL,
[dau_enddate] [datetime] NULL,
[dau_lastupdate] [datetime] NULL,
[dau_assetview] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dau_zoomlevel] [int] NULL,
[dau_capcityview_id] [int] NULL,
[dau_capcityview_yn] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dau_eventview_id] [int] NULL,
[dau_eventview_yn] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dau_listwidth] [int] NULL,
[dau_listwidthcolapsed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dau_listcollapsed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dau_schedlocked] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dausersettings] ADD CONSTRAINT [pk_dausersettings_dau_id] PRIMARY KEY CLUSTERED ([dau_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dausersettings] ADD CONSTRAINT [UQ__dausersettings__34F7534A] UNIQUE NONCLUSTERED ([dau_userid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dausersettings] TO [public]
GO
GRANT INSERT ON  [dbo].[dausersettings] TO [public]
GO
GRANT SELECT ON  [dbo].[dausersettings] TO [public]
GO
GRANT UPDATE ON  [dbo].[dausersettings] TO [public]
GO
