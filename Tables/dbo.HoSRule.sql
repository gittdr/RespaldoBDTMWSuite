CREATE TABLE [dbo].[HoSRule]
(
[HoSRuleId] [int] NOT NULL IDENTITY(1, 1),
[Category] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RuleName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RuleHours] [int] NULL,
[RuleDays] [int] NULL,
[DrivingSecondsAvailable] [int] NULL,
[OnDutySecondsAvailable] [int] NULL,
[CycleResetHours] [int] NULL,
[LastResetDate] [datetime] NULL,
[USResetStartDate] [datetime] NULL,
[CycleTimeSecondsRemaining] [int] NULL,
[RemainingOnSecsUntilBreakRequired] [int] NULL,
[CycleTimeId] [int] NULL,
[ModifiedLast] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HoSRule] ADD CONSTRAINT [PK_dbo.HoSRule] PRIMARY KEY CLUSTERED ([HoSRuleId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HoSRule] ADD CONSTRAINT [FK_dbo.HoSRule_dbo.CycleTime_CycleTimeId] FOREIGN KEY ([CycleTimeId]) REFERENCES [dbo].[CycleTime] ([CycleTimeId]) ON DELETE CASCADE
GO
