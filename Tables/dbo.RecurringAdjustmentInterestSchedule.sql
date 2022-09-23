CREATE TABLE [dbo].[RecurringAdjustmentInterestSchedule]
(
[RecurringAdjustmentInterestScheduleId] [int] NOT NULL IDENTITY(1, 1),
[RecurringAdjustmentId] [int] NOT NULL,
[ScheduleId] [int] NOT NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NULL,
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RecurringAdjustmentInterestSchedule] ADD CONSTRAINT [PK_dbo.RecurringAdjustmentInterestSchedule] PRIMARY KEY CLUSTERED ([RecurringAdjustmentInterestScheduleId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RecurringAdjustmentInterestSchedule] ADD CONSTRAINT [FK_dbo.RecurringAdjustmentInterestSchedule_dbo.Schedule_ScheduleId] FOREIGN KEY ([ScheduleId]) REFERENCES [dbo].[Schedules] ([ScheduleId])
GO
ALTER TABLE [dbo].[RecurringAdjustmentInterestSchedule] ADD CONSTRAINT [FK_RecurringAdjustmentInterestSchedule_RecurringAdjustmentInterest] FOREIGN KEY ([RecurringAdjustmentId]) REFERENCES [dbo].[RecurringAdjustmentInterest] ([RecurringAdjustmentId])
GO
GRANT DELETE ON  [dbo].[RecurringAdjustmentInterestSchedule] TO [public]
GO
GRANT INSERT ON  [dbo].[RecurringAdjustmentInterestSchedule] TO [public]
GO
GRANT SELECT ON  [dbo].[RecurringAdjustmentInterestSchedule] TO [public]
GO
GRANT UPDATE ON  [dbo].[RecurringAdjustmentInterestSchedule] TO [public]
GO
