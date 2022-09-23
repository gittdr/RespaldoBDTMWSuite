CREATE TABLE [dbo].[MetricGradingScaleDetail]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[GradingScaleCode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Grade] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinValue] [decimal] (20, 5) NULL,
[FormatText] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[porcientodelgoal] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricGradingScaleDetail] ADD CONSTRAINT [PK__MetricGradingSca__29E265F5] PRIMARY KEY NONCLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricGradingScaleDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricGradingScaleDetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MetricGradingScaleDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricGradingScaleDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricGradingScaleDetail] TO [public]
GO
