CREATE TABLE [dbo].[PlanningBoardCalendarJoin]
(
[date] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlanningBoardCalendarJoin] ADD CONSTRAINT [PK__PlanningBoardCal__55B5FB3B] PRIMARY KEY CLUSTERED ([date]) ON [PRIMARY]
GO
