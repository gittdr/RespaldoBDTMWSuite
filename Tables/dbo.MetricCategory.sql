CREATE TABLE [dbo].[MetricCategory]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[CategoryCode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Active] [int] NULL CONSTRAINT [DF__MetricCat__Activ__13F324D6] DEFAULT ((1)),
[Sort] [int] NULL CONSTRAINT [DF__MetricCate__Sort__14E7490F] DEFAULT ((0)),
[ShowTime] [int] NOT NULL CONSTRAINT [DF__MetricCat__ShowT__15DB6D48] DEFAULT ((4)),
[Caption] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaptionFull] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PagePassword] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MetricCat__PageP__16CF9181] DEFAULT (''),
[LoopGraphs] [int] NULL CONSTRAINT [DF__MetricCat__LoopG__17C3B5BA] DEFAULT ((1)),
[LastGraphMetricSN] [int] NULL CONSTRAINT [DF__MetricCat__LastG__18B7D9F3] DEFAULT ((0)),
[Parent] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParentCaption] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShowFullTimeFrameDay] [int] NULL CONSTRAINT [DF__MetricCat__ShowF__54CCC3FA] DEFAULT ((0)),
[ShowFullTimeFrameWeek] [int] NULL CONSTRAINT [DF__MetricCat__ShowF__55C0E833] DEFAULT ((0)),
[ShowFullTimeFrameMonth] [int] NULL CONSTRAINT [DF__MetricCat__ShowF__56B50C6C] DEFAULT ((0)),
[ShowFullTimeFrameQuarter] [int] NULL CONSTRAINT [DF__MetricCat__ShowF__57A930A5] DEFAULT ((0)),
[ShowFullTimeFrameYear] [int] NULL CONSTRAINT [DF__MetricCat__ShowF__589D54DE] DEFAULT ((0)),
[LastBriefingDate] [datetime] NULL CONSTRAINT [DF__MetricCat__LastB__68D3BCA7] DEFAULT (getdate()),
[ScheduleBriefing] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__MetricCat__Sched__69C7E0E0] DEFAULT ('0'),
[TimeValue] [int] NULL CONSTRAINT [DF__MetricCat__TimeV__6ABC0519] DEFAULT (NULL),
[TimeType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__MetricCat__TimeT__6BB02952] DEFAULT (NULL),
[BriefingEmailAddress] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__MetricCat__Brief__6CA44D8B] DEFAULT (NULL),
[ShowFullTimeFrameFiscalYear] [int] NULL CONSTRAINT [DF__MetricCat__ShowF__6D9871C4] DEFAULT ((0)),
[DateOrderLeftToRight] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllowChartDisplay_YN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricCategory] ADD CONSTRAINT [PK__MetricCategory__12FF009D] PRIMARY KEY NONCLUSTERED ([CategoryCode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricCategory] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricCategory] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MetricCategory] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricCategory] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricCategory] TO [public]
GO
