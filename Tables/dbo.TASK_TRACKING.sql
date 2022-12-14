CREATE TABLE [dbo].[TASK_TRACKING]
(
[TASK_TRACKING_ID] [int] NOT NULL IDENTITY(1, 1),
[TASK_ID] [int] NULL,
[USER_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REMINDER_ENABLED] [bit] NULL,
[REMINDER_INTERVAL] [int] NULL,
[REMINDER_UNITS] [int] NULL,
[SNOOZED] [bit] NULL,
[SNOOZE_INTERVAL] [int] NULL,
[SNOOZE_UNITS] [int] NULL,
[SNOOZE_TIME] [datetime] NULL,
[NOTIFIED] [bit] NULL,
[NOTIFIED_DATE] [datetime] NULL,
[VIEWED] [bit] NULL,
[VIEWED_DATE] [datetime] NULL,
[CREATED_DATE] [datetime] NULL,
[CREATED_USER] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MODIFIED_DATE] [datetime] NULL,
[MODIFIED_USER] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DISMISSED] [bit] NULL,
[DISMISSED_DATE] [datetime] NULL,
[REMINDED] [bit] NULL,
[REMINDED_FIRST_TIME] [datetime] NULL,
[REMINDER_SYNCED] [bit] NULL,
[REMINDER_SYNCED_DATE] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TASK_TRACKING] ADD CONSTRAINT [PK_TASK_TRACKING] PRIMARY KEY CLUSTERED ([TASK_TRACKING_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TASK_TRACKING] TO [public]
GO
GRANT INSERT ON  [dbo].[TASK_TRACKING] TO [public]
GO
GRANT SELECT ON  [dbo].[TASK_TRACKING] TO [public]
GO
GRANT UPDATE ON  [dbo].[TASK_TRACKING] TO [public]
GO
