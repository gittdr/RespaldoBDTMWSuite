CREATE TABLE [dbo].[MetricCacheMajorCustMiles]
(
[LastUpdatedDate] [datetime] NULL,
[BilledMiles] [int] NULL,
[BilltoName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateRange] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChangeFrom4WeeksAgo] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FourWeeksAgoMiles] [int] NULL,
[AverageForLast6Months] [int] NULL,
[ChangeFromAve] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rank] [int] NULL,
[DateStart] [datetime] NULL,
[DateEnd] [datetime] NULL,
[TopN] [int] NULL,
[UseLast7DaysFromDateEnd] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Result] [decimal] (20, 5) NULL,
[ThisCount] [decimal] (20, 5) NULL,
[ThisTotal] [decimal] (20, 5) NULL,
[OnlyRevClass1List] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OnlyRevClass2List] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OnlyRevClass3List] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OnlyRevClass4List] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SN] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricCacheMajorCustMiles] ADD CONSTRAINT [PK__MetricCacheMajor__3944A516] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
