CREATE TABLE [dbo].[ScheduleJob]
(
[job_id] [int] NOT NULL IDENTITY(1, 1),
[job_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[job_dll] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[job_classname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[job_waitseconds] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ScheduleJob] ADD CONSTRAINT [PK__ScheduleJob__0AAC13C3] PRIMARY KEY CLUSTERED ([job_id]) ON [PRIMARY]
GO
