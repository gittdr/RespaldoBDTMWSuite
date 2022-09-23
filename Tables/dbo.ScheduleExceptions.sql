CREATE TABLE [dbo].[ScheduleExceptions]
(
[ScheduleExceptionId] [int] NOT NULL IDENTITY(1, 1),
[ScheduleId] [int] NOT NULL,
[ScheduleExceptionType] [int] NOT NULL,
[ExceptionDate] [datetime] NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__ScheduleE__Creat__4DEF1888] DEFAULT (user_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__ScheduleE__Creat__4EE33CC1] DEFAULT (getdate()),
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__ScheduleE__LastU__4FD760FA] DEFAULT (user_name()),
[LastUpdatedDate] [datetime] NOT NULL CONSTRAINT [DF__ScheduleE__LastU__50CB8533] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ScheduleExceptions] ADD CONSTRAINT [PK__ScheduleExceptio__4CFAF44F] PRIMARY KEY CLUSTERED ([ScheduleExceptionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ScheduleId] ON [dbo].[ScheduleExceptions] ([ScheduleId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ScheduleExceptions] ADD CONSTRAINT [ScheduleException_Schedule] FOREIGN KEY ([ScheduleId]) REFERENCES [dbo].[Schedules] ([ScheduleId]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[ScheduleExceptions] TO [public]
GO
GRANT INSERT ON  [dbo].[ScheduleExceptions] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ScheduleExceptions] TO [public]
GO
GRANT SELECT ON  [dbo].[ScheduleExceptions] TO [public]
GO
GRANT UPDATE ON  [dbo].[ScheduleExceptions] TO [public]
GO
