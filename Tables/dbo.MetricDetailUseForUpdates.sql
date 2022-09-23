CREATE TABLE [dbo].[MetricDetailUseForUpdates]
(
[SPID] [int] NULL,
[DateInserted] [datetime] NULL CONSTRAINT [DF__MetricDet__DateI__41B9EF86] DEFAULT (getdate()),
[MetricCode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DailyValue] [decimal] (20, 5) NULL,
[DailyCount] [decimal] (20, 5) NULL,
[DailyTotal] [decimal] (20, 5) NULL,
[Upd_Summary] [datetime] NULL,
[PlainDate] [datetime] NOT NULL,
[ThisWTD] [decimal] (20, 5) NULL,
[ThisMTD] [decimal] (20, 5) NULL,
[ThisQTD] [decimal] (20, 5) NULL,
[ThisYTD] [decimal] (20, 5) NULL,
[WeeklyAve] [decimal] (20, 5) NULL,
[MonthlyAve] [decimal] (20, 5) NULL,
[QuarterlyAve] [decimal] (20, 5) NULL,
[YearlyAve] [decimal] (20, 5) NULL,
[PlainDayOfWeek] [int] NULL,
[PlainWeek] [int] NULL,
[PlainMonth] [int] NULL,
[PlainQuarter] [int] NULL,
[PlainYear] [int] NULL,
[PlainYearWeek] [int] NULL,
[RecordExists] [int] NULL CONSTRAINT [DF__MetricDet__Recor__42AE13BF] DEFAULT ((0)),
[upd_daily] [datetime] NULL,
[ThisFiscalYTD] [decimal] (20, 5) NULL,
[FiscalYearlyAve] [decimal] (20, 5) NULL,
[PlainFiscalYear] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricDetailUseForUpdates] ADD CONSTRAINT [AutoPK_MetricDetailUseForUpdates_PlainDate_MetricCode] PRIMARY KEY CLUSTERED ([PlainDate], [MetricCode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricDetailUseForUpdates] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricDetailUseForUpdates] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricDetailUseForUpdates] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricDetailUseForUpdates] TO [public]
GO
