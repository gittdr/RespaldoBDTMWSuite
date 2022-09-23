CREATE TABLE [dbo].[estatschedule]
(
[rpt_sched_id] [int] NOT NULL IDENTITY(1, 1),
[login] [varchar] (132) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rpt_id] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rpt_period] [int] NULL,
[rpt_active] [int] NOT NULL,
[rpt_email] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_email_subject] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_freq] [int] NOT NULL,
[rpt_weekday] [char] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_nthday] [int] NULL,
[rpt_start_time] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rpt_stop_time] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_lastrun] [datetime] NULL,
[rpt_nextrun] [datetime] NULL,
[rpt_sched_lastupdated] [datetime] NULL,
[rpt_last_run_successful] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_last_run_message] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[estatschedule] ADD CONSTRAINT [PK_estat_schedule] PRIMARY KEY NONCLUSTERED ([rpt_sched_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_estat_schedule] ON [dbo].[estatschedule] ([login]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_estatschedule_1] ON [dbo].[estatschedule] ([rpt_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_estatschedule] ON [dbo].[estatschedule] ([rpt_nextrun]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[estatschedule] TO [public]
GO
GRANT INSERT ON  [dbo].[estatschedule] TO [public]
GO
GRANT SELECT ON  [dbo].[estatschedule] TO [public]
GO
GRANT UPDATE ON  [dbo].[estatschedule] TO [public]
GO
