CREATE TABLE [dbo].[WatchDogScheduleObject]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ObjectXML] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[objDescription] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScheduleName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WatchDogScheduleObject] ADD CONSTRAINT [PK__WatchDogSchedule__33D5E483] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WatchDogScheduleObject] TO [public]
GO
GRANT INSERT ON  [dbo].[WatchDogScheduleObject] TO [public]
GO
GRANT SELECT ON  [dbo].[WatchDogScheduleObject] TO [public]
GO
GRANT UPDATE ON  [dbo].[WatchDogScheduleObject] TO [public]
GO
