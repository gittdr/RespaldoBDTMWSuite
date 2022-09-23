CREATE TABLE [dbo].[OutageHeader]
(
[OutageID] [int] NOT NULL IDENTITY(1, 1),
[StartDate] [datetime] NOT NULL CONSTRAINT [DF_OutageHeader_StartDate] DEFAULT (getdate()),
[EndDate] [datetime] NOT NULL CONSTRAINT [DF_OutageHeader_EndDate] DEFAULT (getdate()),
[Comment] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OutageHeader_Shipper] DEFAULT ('UNKNOWN'),
[OutageType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OutageHeader_OutageHeader] DEFAULT ('OUTAGE'),
[IsNonFunctional] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OutageHeader_IsNonFunctional] DEFAULT ('N'),
[IsDailyAllocation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OutageHeader_IsDailyAllocation] DEFAULT ('N'),
[DailyAllocation] [int] NOT NULL CONSTRAINT [DF_OutageHeader_dailyAllocation] DEFAULT ((0)),
[IsWeeklyAllocation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OutageHeader_IsWeeklyAllocation] DEFAULT ('N'),
[WeeklyAllocation] [int] NOT NULL CONSTRAINT [DF_OutageHeader_WeeklyAllocation] DEFAULT ((0)),
[IsMonthlyAllocation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OutageHeader_IsMonthlyAllocation] DEFAULT ('N'),
[MonthlyAllocation] [int] NOT NULL CONSTRAINT [DF_OutageHeader_MonthlyAllocation] DEFAULT ((0)),
[IsTotalAllocation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OutageHeader_IsTotalAllocation] DEFAULT ('N'),
[TotalAllocation] [int] NOT NULL CONSTRAINT [DF_OutageHeader_TotalAllocation] DEFAULT ((0)),
[IsRecurring] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OutageHeader_IsRecurring] DEFAULT ('N'),
[RecursFromID] [int] NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_OutageHeader_CreatedDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_OutageHEader_ModifiedDate] DEFAULT (getdate()),
[IsPublished] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OutageHeader_IsPublished] DEFAULT ('N'),
[PublishedDate] [datetime] NULL,
[IsMinimum] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OutageHeader_IsMinimum] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OutageHeader] ADD CONSTRAINT [PK_OutageHeader] PRIMARY KEY CLUSTERED ([OutageID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OutageHeader] TO [public]
GO
GRANT INSERT ON  [dbo].[OutageHeader] TO [public]
GO
GRANT SELECT ON  [dbo].[OutageHeader] TO [public]
GO
GRANT UPDATE ON  [dbo].[OutageHeader] TO [public]
GO
