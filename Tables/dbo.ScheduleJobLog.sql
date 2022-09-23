CREATE TABLE [dbo].[ScheduleJobLog]
(
[log_id] [int] NOT NULL IDENTITY(1, 1),
[job_id] [int] NOT NULL,
[log_date] [datetime] NOT NULL,
[log_description] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ScheduleJobLog] ADD CONSTRAINT [PK__ScheduleJobLog__0C945C35] PRIMARY KEY CLUSTERED ([log_id]) ON [PRIMARY]
GO
