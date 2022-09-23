CREATE TABLE [dbo].[PowerState]
(
[PowerStateID] [int] NOT NULL IDENTITY(1, 1),
[CompanyId] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PowerId] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadId] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanId] [int] NULL,
[BreakEnd] [datetime] NULL,
[BreakEndText] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Capacity] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delay] [decimal] (10, 4) NULL,
[DelayStopSequence] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispatchPta] [datetime] NULL,
[DispatchPtaCity] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispatchPtaPostal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispatchPtaState] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispatchPtaText] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Division] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DriveHoursLeft] [decimal] (10, 4) NULL,
[Driver1] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver1HomeCity] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver1HomeDate] [datetime] NULL,
[Driver1HomeDateText] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver1HomePostal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver1HomeState] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver2] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver2HomeCity] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver2HomeDate] [datetime] NULL,
[Driver2HomeDateText] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver2HomePostal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver2HomeState] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DutyHoursLeft] [decimal] (10, 4) NULL,
[DutyHoursLeftWeek] [decimal] (10, 4) NULL,
[DutySpan] [decimal] (10, 4) NULL,
[EstimatedPta] [datetime] NULL,
[EstimatedPtaCity] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EstimatedPtaCountry] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EstimatedPtaPeriod] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EstimatedPtaPostal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EstimatedPtaState] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EstimatedPtaText] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HosSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HoursAvailable] [decimal] (10, 4) NULL,
[HoursAvailable11] [decimal] (10, 4) NULL,
[HoursAvailable14] [decimal] (10, 4) NULL,
[HoursAvailable70] [decimal] (10, 4) NULL,
[HoursBreak] [decimal] (10, 4) NULL,
[HoursDriven] [decimal] (10, 4) NULL,
[HoursLate] [decimal] (10, 4) NULL,
[HoursLatePta] [decimal] (10, 4) NULL,
[HoursOff] [decimal] (10, 4) NULL,
[HoursRested] [decimal] (10, 4) NULL,
[HoursSinceBreak] [decimal] (10, 4) NULL,
[HoursSincePta] [decimal] (10, 4) NULL,
[HoursStale] [decimal] (10, 4) NULL,
[HoursWorked] [decimal] (10, 4) NULL,
[LateStopId] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LateStopSequence] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MilesHome1] [decimal] (10, 4) NULL,
[MilesHome2] [decimal] (10, 4) NULL,
[MilesOffPta] [decimal] (10, 4) NULL,
[MilesSinceBreak] [decimal] (10, 4) NULL,
[NextLoad] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NextOrder] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderId] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ping] [datetime] NULL,
[PingText] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrePlans] [int] NULL,
[RestBegin] [datetime] NULL,
[RestBeginText] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalDelay] [decimal] (10, 4) NULL,
[WorkStatus] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedBy] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdated] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PowerState] ADD CONSTRAINT [pk_PowerState] PRIMARY KEY CLUSTERED ([PowerStateID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_PowerState_CompanyIDPowerID] ON [dbo].[PowerState] ([CompanyId], [PowerId]) INCLUDE ([HoursAvailable11], [HoursAvailable14], [HoursAvailable70], [DriveHoursLeft], [DutyHoursLeft], [DutyHoursLeftWeek]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PowerState] TO [public]
GO
GRANT INSERT ON  [dbo].[PowerState] TO [public]
GO
GRANT REFERENCES ON  [dbo].[PowerState] TO [public]
GO
GRANT SELECT ON  [dbo].[PowerState] TO [public]
GO
GRANT UPDATE ON  [dbo].[PowerState] TO [public]
GO
