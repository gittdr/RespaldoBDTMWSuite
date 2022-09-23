CREATE TABLE [dbo].[ResNowLoadBalanceSummary]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[InCount] [int] NOT NULL CONSTRAINT [DF__ResNowLoa__InCou__631AE351] DEFAULT ((0)),
[OutCount] [int] NOT NULL CONSTRAINT [DF__ResNowLoa__OutCo__640F078A] DEFAULT ((0)),
[LastUpdate] [datetime] NOT NULL,
[MetricCode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Area] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ResNowLoadBalanceSummary] ADD CONSTRAINT [PK__ResNowLoadBalanc__6226BF18] PRIMARY KEY NONCLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ResNowLoadBalanceSummary] TO [public]
GO
GRANT INSERT ON  [dbo].[ResNowLoadBalanceSummary] TO [public]
GO
GRANT SELECT ON  [dbo].[ResNowLoadBalanceSummary] TO [public]
GO
GRANT UPDATE ON  [dbo].[ResNowLoadBalanceSummary] TO [public]
GO
