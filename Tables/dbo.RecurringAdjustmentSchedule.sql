CREATE TABLE [dbo].[RecurringAdjustmentSchedule]
(
[RecurringAdjustmentScheduleId] [int] NOT NULL IDENTITY(1, 1),
[RecurringAdjustmentId] [int] NOT NULL,
[ScheduleId] [int] NOT NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NULL,
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RecurringAdjustmentSchedule] ADD CONSTRAINT [PK_dbo.RecurringAdjustmentSchedule] PRIMARY KEY CLUSTERED ([RecurringAdjustmentScheduleId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RecurringAdjustmentSchedule] ADD CONSTRAINT [FK_dbo.RecurringAdjustmentSchedule_dbo.RecurringAdjustment_RecurringAdjustmentId] FOREIGN KEY ([RecurringAdjustmentId]) REFERENCES [dbo].[RecurringAdjustment] ([RecurringAdjustmentId])
GO
ALTER TABLE [dbo].[RecurringAdjustmentSchedule] ADD CONSTRAINT [FK_dbo.RecurringAdjustmentSchedule_dbo.Schedule_ScheduleId] FOREIGN KEY ([ScheduleId]) REFERENCES [dbo].[Schedules] ([ScheduleId])
GO
GRANT DELETE ON  [dbo].[RecurringAdjustmentSchedule] TO [public]
GO
GRANT INSERT ON  [dbo].[RecurringAdjustmentSchedule] TO [public]
GO
GRANT SELECT ON  [dbo].[RecurringAdjustmentSchedule] TO [public]
GO
GRANT UPDATE ON  [dbo].[RecurringAdjustmentSchedule] TO [public]
GO
