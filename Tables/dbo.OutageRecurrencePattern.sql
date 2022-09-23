CREATE TABLE [dbo].[OutageRecurrencePattern]
(
[OutageID] [int] NOT NULL,
[RecurStartDate] [datetime] NOT NULL CONSTRAINT [DF_OutageRecurrencePattern_StartDate] DEFAULT (getdate()),
[RecurEndDate] [datetime] NOT NULL CONSTRAINT [DF_OutageRecurrencePattern_EndDate] DEFAULT (getdate()),
[IsDailyRecurrence] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OutageRecurrencePattern_IsDailyRecurrence] DEFAULT ('N'),
[DailyEveryXDays] [int] NOT NULL CONSTRAINT [DF_OutageRecurrencePattern_DailyEveryXDays] DEFAULT ((0)),
[DailyEveryWeekday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OutageRecurrencePattern_DailyEveryWeekday] DEFAULT ('N'),
[IsWeeklyRecurrence] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OutageRecurrencePattern_IsWeeklyRecurrence] DEFAULT ('N'),
[WeeklyRecurEveryXWeeks] [int] NOT NULL CONSTRAINT [DF_OutageRecurrencePattern_WeeklyRecurEveryXWeeks] DEFAULT ((0)),
[WeeklyRecursOnSunday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OutageRecurrencePattern_WeeklyRecursOnSunday] DEFAULT ('N'),
[WeeklyRecursOnMonday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OutageRecurrencePattern_WeeklyRecursOnMonday] DEFAULT ('N'),
[WeeklyRecursOnTuesday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OutageRecurrencePattern_WeeklyRecursOnTuesday] DEFAULT ('N'),
[WeeklyRecursOnWednesday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OutageRecurrencePattern_WeeklyRecursOnWednesday] DEFAULT ('N'),
[WeeklyRecursOnThursday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OutageRecurrencePattern_WeeklyRecursOnThursday] DEFAULT ('N'),
[WeeklyRecursOnFriday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OutageRecurrencePattern_WeeklyRecursOnFriday] DEFAULT ('N'),
[WeeklyRecursOnSaturday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OutageRecurrencePattern_WeeklyRecursOnSaturday] DEFAULT ('N'),
[IsMonthlyRecurrence] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OutageRecurrencePattern_IsMonthlyRecurrence] DEFAULT ('N'),
[MonthlyDayNumber] [int] NOT NULL CONSTRAINT [DF_OutageRecurrencePattern_MonthlyDayNumber] DEFAULT ((0)),
[MonthlyEveryXMonths] [int] NOT NULL CONSTRAINT [DF_OutageRecurrencePattern_MonthlyEveryXMonths] DEFAULT ((0)),
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_OutageRecurrencePattern_CreatedDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_OutageRecurrencePattern_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OutageRecurrencePattern] ADD CONSTRAINT [PK_OutageRecurrencePattern] PRIMARY KEY CLUSTERED ([OutageID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OutageRecurrencePattern] TO [public]
GO
GRANT INSERT ON  [dbo].[OutageRecurrencePattern] TO [public]
GO
GRANT SELECT ON  [dbo].[OutageRecurrencePattern] TO [public]
GO
GRANT UPDATE ON  [dbo].[OutageRecurrencePattern] TO [public]
GO
