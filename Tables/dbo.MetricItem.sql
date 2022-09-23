CREATE TABLE [dbo].[MetricItem]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[MetricCode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Active] [int] NOT NULL CONSTRAINT [DF__MetricIte__Activ__0C52030E] DEFAULT ((1)),
[Sort] [int] NOT NULL CONSTRAINT [DF__MetricItem__Sort__0D462747] DEFAULT ((1)),
[FormatText] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MetricIte__Forma__0E3A4B80] DEFAULT (''),
[NumDigitsAfterDecimal] [int] NOT NULL CONSTRAINT [DF__MetricIte__NumDi__0F2E6FB9] DEFAULT ((0)),
[PlusDeltaIsGood] [int] NOT NULL CONSTRAINT [DF__MetricIte__PlusD__102293F2] DEFAULT ((1)),
[Cumulative] [int] NOT NULL CONSTRAINT [DF__MetricIte__Cumul__1116B82B] DEFAULT ((0)),
[Caption] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaptionFull] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcedureName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NULL,
[GradingScaleCode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScheduleSN] [int] NULL,
[DetailFilename] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GoalDay] [decimal] (20, 5) NULL,
[GoalWeek] [decimal] (20, 5) NULL,
[GoalMonth] [decimal] (20, 5) NULL,
[GoalQuarter] [decimal] (20, 5) NULL,
[GoalYear] [decimal] (20, 5) NULL,
[LastUpd] [datetime] NULL,
[PlainDate] [datetime] NULL,
[ThisDay] [decimal] (20, 5) NULL,
[ThisWeek] [decimal] (20, 5) NULL,
[ThisMonth] [decimal] (20, 5) NULL,
[ThisQuarter] [decimal] (20, 5) NULL,
[ThisYear] [decimal] (20, 5) NULL,
[LastDay] [decimal] (20, 5) NULL,
[LastWeek] [decimal] (20, 5) NULL,
[LastMonth] [decimal] (20, 5) NULL,
[LastQuarter] [decimal] (20, 5) NULL,
[LastYear] [decimal] (20, 5) NULL,
[ThresholdAlertEmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThresholdAlertValue] [decimal] (20, 5) NULL,
[ThresholdOperator] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CachedDetailYN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CacheRefreshAgeMaxMinutes] [int] NULL,
[DoNotIncludeTotalForNonBusinessDayYN] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefreshHistoryYN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShowDetailByDefaultYN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RNIActiveLanguage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RNILocaleID] [int] NULL,
[RNIDefaultCurrency] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RNICurrencyDateType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RNICurrencySymbol] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RNIDateFormat] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RNINumericFormat] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BriefingEmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LayerSN] [int] NULL,
[IncludeOnReportCardYN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__MetricIte__Inclu__5A859D50] DEFAULT ('Y'),
[LastRunDate] [datetime] NULL CONSTRAINT [DF__MetricIte__LastR__5B79C189] DEFAULT (getdate()),
[ScheduleMetric] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__MetricIte__Sched__5C6DE5C2] DEFAULT ('0'),
[TimeValue] [int] NULL CONSTRAINT [DF__MetricIte__TimeV__5D6209FB] DEFAULT (NULL),
[TimeType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__MetricIte__TimeT__5E562E34] DEFAULT (NULL),
[GoalNumDigitsAfterDecimal] [int] NULL,
[GoalFiscalYear] [decimal] (20, 5) NULL,
[ThisFiscalYear] [decimal] (20, 5) NULL,
[LastFiscalYear] [decimal] (20, 5) NULL,
[Annualize] [int] NULL,
[ExtrapolateGradesForCumulativeFromDaily] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtrapolateGradesByCountingBusinessDays] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSourceSN] [int] NULL,
[BadData] [int] NULL,
[MetricTimeout] [int] NULL CONSTRAINT [DF__MetricIte__Metri__1D4784E6] DEFAULT ((30))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricItem] ADD CONSTRAINT [PK__MetricItem__0B5DDED5] PRIMARY KEY NONCLUSTERED ([MetricCode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricItem] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricItem] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MetricItem] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricItem] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricItem] TO [public]
GO
