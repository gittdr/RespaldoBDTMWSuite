CREATE TABLE [dbo].[AutomationIFSchedule]
(
[sch_TaskName] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sch_Minute] [varchar] (180) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sch_Hour] [varchar] (72) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sch_MonthDay] [varchar] (93) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sch_Month] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sch_WeekDay] [varchar] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sch_Command] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AutomationIFSchedule] ADD CONSTRAINT [PK__AutomationIFSche__38A52304] PRIMARY KEY CLUSTERED ([sch_TaskName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[AutomationIFSchedule] TO [public]
GO
GRANT INSERT ON  [dbo].[AutomationIFSchedule] TO [public]
GO
GRANT REFERENCES ON  [dbo].[AutomationIFSchedule] TO [public]
GO
GRANT SELECT ON  [dbo].[AutomationIFSchedule] TO [public]
GO
GRANT UPDATE ON  [dbo].[AutomationIFSchedule] TO [public]
GO
