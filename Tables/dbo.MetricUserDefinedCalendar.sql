CREATE TABLE [dbo].[MetricUserDefinedCalendar]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[Calendar_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Date_Start] [datetime] NULL,
[Date_End] [datetime] NULL,
[Period] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Quarter] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Year] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricUserDefinedCalendar] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricUserDefinedCalendar] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricUserDefinedCalendar] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricUserDefinedCalendar] TO [public]
GO
