CREATE TABLE [dbo].[MetricTemp]
(
[ProcName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Result] [decimal] (20, 5) NULL,
[ThisCount] [decimal] (20, 5) NULL,
[ThisTotal] [decimal] (20, 5) NULL,
[DateLow] [datetime] NULL,
[DateHigh] [datetime] NULL,
[UseMetricParms] [int] NULL,
[ShowDetail] [int] NULL,
[SN] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricTemp] ADD CONSTRAINT [PK__MetricTemp__2BCAAE67] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricTemp] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricTemp] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MetricTemp] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricTemp] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricTemp] TO [public]
GO
