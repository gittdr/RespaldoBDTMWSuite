CREATE TABLE [dbo].[MetricResultsNowBuffer]
(
[spid] [int] NOT NULL,
[ins_dt] [datetime] NULL CONSTRAINT [DF__MetricRes__ins_d__1C5360AD] DEFAULT (getdate()),
[Result] [float] NULL,
[Numerator] [float] NULL,
[Denominator] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricResultsNowBuffer] ADD CONSTRAINT [AutoPK_MetricResultsNowBuffer_SPID] PRIMARY KEY CLUSTERED ([spid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricResultsNowBuffer] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricResultsNowBuffer] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricResultsNowBuffer] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricResultsNowBuffer] TO [public]
GO
