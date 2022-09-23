CREATE TABLE [dbo].[MetricDetail]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[MetricCode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PlainDate] [datetime] NOT NULL CONSTRAINT [DF__MetricDet__Plain__1F64D782] DEFAULT (CONVERT([datetime],CONVERT([varchar](10),getdate(),(101)),0)),
[Upd_Daily] [datetime] NULL,
[Upd_Summary] [datetime] NULL,
[RunDurationLast] [decimal] (9, 3) NULL,
[RunDurationMax] [decimal] (9, 3) NULL,
[RunDurationMin] [decimal] (9, 3) NULL,
[DailyCount] [decimal] (20, 5) NULL,
[DailyTotal] [decimal] (20, 5) NULL,
[DailyValue] [decimal] (20, 5) NULL CONSTRAINT [DF__MetricDet__Daily__2058FBBB] DEFAULT ((0)),
[ThisYTD] [decimal] (20, 5) NULL,
[ThisQTD] [decimal] (20, 5) NULL,
[ThisMTD] [decimal] (20, 5) NULL,
[ThisWTD] [decimal] (20, 5) NULL,
[YearlyAve] [decimal] (20, 5) NULL,
[QuarterlyAve] [decimal] (20, 5) NULL,
[MonthlyAve] [decimal] (20, 5) NULL,
[WeeklyAve] [decimal] (20, 5) NULL,
[GoalDay] [decimal] (20, 5) NULL,
[GoalWeek] [decimal] (20, 5) NULL,
[GoalMonth] [decimal] (20, 5) NULL,
[GoalQuarter] [decimal] (20, 5) NULL,
[GoalYear] [decimal] (20, 5) NULL,
[PlainYear] [int] NULL,
[PlainQuarter] [int] NULL,
[PlainMonth] [int] NULL,
[PlainWeek] [int] NULL,
[PlainDayOfWeek] [int] NULL,
[PlainYearWeek] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLScriptRun] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FiscalYearlyAve] [decimal] (20, 5) NULL,
[ThisFiscalYTD] [decimal] (20, 5) NULL,
[GoalFiscalYear] [decimal] (20, 5) NULL,
[PlainFiscalYear] [int] NULL CONSTRAINT [DF__MetricDet__Plain__6E8C95FD] DEFAULT ((0)),
[Upd_SummaryFiscal] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricDetail] ADD CONSTRAINT [PK__MetricDetail_plaindate_metriccode] PRIMARY KEY CLUSTERED ([PlainDate], [MetricCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxMetricDetail_MetricCode] ON [dbo].[MetricDetail] ([MetricCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxMetricDetail_PlainMonth] ON [dbo].[MetricDetail] ([PlainMonth]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxMetricDetail_PlainQuarter] ON [dbo].[MetricDetail] ([PlainQuarter]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxMetricDetail_PlainYear] ON [dbo].[MetricDetail] ([PlainYear]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxMetricDetail_PlainYearWeek] ON [dbo].[MetricDetail] ([PlainYearWeek]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricDetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MetricDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricDetail] TO [public]
GO
