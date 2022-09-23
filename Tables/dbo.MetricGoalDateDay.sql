CREATE TABLE [dbo].[MetricGoalDateDay]
(
[idgoalday] [int] NOT NULL IDENTITY(1, 1),
[day] [datetime] NOT NULL,
[metriccode] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[valorgoal] [decimal] (20, 5) NOT NULL,
[ingresado] [int] NULL
) ON [PRIMARY]
GO
