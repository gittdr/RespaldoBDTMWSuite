CREATE TABLE [dbo].[ScheduleTemplateHeader]
(
[sth_id] [int] NOT NULL IDENTITY(1, 1),
[sth_terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sth_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sth_calendarweek] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sth_lastupdateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sth_lastupdatedate] [datetime] NULL,
[sth_default_shift] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sth_default_start] [datetime] NULL,
[sth_default_end] [datetime] NULL,
[sth_retired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sth_allow_backupdrv] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__ScheduleT__sth_a__5BC3DA4C] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ScheduleTemplateHeader] ADD CONSTRAINT [PK_ScheduleTemplateHeader_sth_id] PRIMARY KEY CLUSTERED ([sth_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ScheduleTemplateHeader] TO [public]
GO
GRANT INSERT ON  [dbo].[ScheduleTemplateHeader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ScheduleTemplateHeader] TO [public]
GO
GRANT SELECT ON  [dbo].[ScheduleTemplateHeader] TO [public]
GO
GRANT UPDATE ON  [dbo].[ScheduleTemplateHeader] TO [public]
GO
