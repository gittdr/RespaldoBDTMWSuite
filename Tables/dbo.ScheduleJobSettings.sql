CREATE TABLE [dbo].[ScheduleJobSettings]
(
[job_id] [int] NOT NULL,
[set_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[set_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[set_savevalue] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ScheduleJobSettings] ADD CONSTRAINT [PK__ScheduleJobSetti__0E7CA4A7] PRIMARY KEY CLUSTERED ([job_id], [set_name]) ON [PRIMARY]
GO
