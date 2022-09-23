CREATE TABLE [dbo].[ScheduleTemplateDetail]
(
[std_id] [int] NOT NULL IDENTITY(1, 1),
[sth_id] [int] NOT NULL,
[std_sequence] [int] NOT NULL,
[std_shift] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[std_shift_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[std_start] [datetime] NOT NULL,
[std_end] [datetime] NOT NULL,
[std_lastupdateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[std_lastupdatedate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ScheduleTemplateDetail] ADD CONSTRAINT [PK_ScheduleTemplateDetail_std_id] PRIMARY KEY CLUSTERED ([std_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ScheduleTemplateDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[ScheduleTemplateDetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ScheduleTemplateDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[ScheduleTemplateDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[ScheduleTemplateDetail] TO [public]
GO
