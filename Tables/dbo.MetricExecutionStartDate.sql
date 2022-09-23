CREATE TABLE [dbo].[MetricExecutionStartDate]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[spid] [int] NULL,
[StartDate] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricExecutionStartDate] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricExecutionStartDate] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricExecutionStartDate] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricExecutionStartDate] TO [public]
GO
