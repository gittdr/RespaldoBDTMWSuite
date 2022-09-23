CREATE TABLE [dbo].[MetricBusinessDays]
(
[PlainDate] [datetime] NOT NULL CONSTRAINT [DF__MetricBus__Plain__318387BD] DEFAULT (CONVERT([datetime],CONVERT([varchar](10),getdate(),(101)),0)),
[BusinessDay] [int] NULL CONSTRAINT [DF__MetricBus__Busin__3277ABF6] DEFAULT ((1)),
[Weight] [decimal] (20, 5) NULL,
[date_key] [int] NOT NULL IDENTITY(1, 1),
[date_DOW] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_DOWName] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_DOM] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_DOQ] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_DOY] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_Week] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_Month] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_MonthName] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_Quarter] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_Year] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_YearMonth] [char] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_YearQuarter] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_Runweek] [int] NULL,
[date_Special] [char] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_DayCategory] [char] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_BusinessDay] [smallint] NULL,
[date_FDOQ] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_FDOY] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_FWeek] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_FMonth] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_FQuarter] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_FYear] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_FYearMonth] [char] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_FYearQuarter] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_AltMonth01] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_AltQuarter01] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_AltYear01] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_YearWeek] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricBusinessDays] ADD CONSTRAINT [pk_BusinessDaysPlainDate] PRIMARY KEY CLUSTERED ([PlainDate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricBusinessDays] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricBusinessDays] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricBusinessDays] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricBusinessDays] TO [public]
GO
