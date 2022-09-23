CREATE TABLE [dbo].[Metric_RTDefinitions]
(
[rt_SN] [int] NOT NULL IDENTITY(1, 1),
[rt_DefName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_HomeDefinitionMode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_HomeValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_BeginStopEvents] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_ReturnDefinitionMode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_ReturnValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_EndStopEvents] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_MaxTimeFrameInDays] [int] NULL,
[rt_PeekAheadCompletionYN] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_DailyHours] [float] NULL,
[rt_AvgMPH] [float] NULL,
[rt_FuelRate] [float] NULL,
[rt_FuelCostInSettlementsParameter] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_FuelInSettlementValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Metric_RTDefinitions] TO [public]
GO
GRANT INSERT ON  [dbo].[Metric_RTDefinitions] TO [public]
GO
GRANT SELECT ON  [dbo].[Metric_RTDefinitions] TO [public]
GO
GRANT UPDATE ON  [dbo].[Metric_RTDefinitions] TO [public]
GO
