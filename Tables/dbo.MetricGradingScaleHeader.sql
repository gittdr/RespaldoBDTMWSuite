CREATE TABLE [dbo].[MetricGradingScaleHeader]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[GradingScaleCode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SystemScale] [int] NULL CONSTRAINT [DF__MetricGra__Syste__2705F94A] DEFAULT ((0)),
[PlusDeltaIsGood] [int] NULL CONSTRAINT [DF__MetricGra__PlusD__27FA1D83] DEFAULT ((1)),
[FormatText] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricGradingScaleHeader] ADD CONSTRAINT [PK__MetricGradingSca__2611D511] PRIMARY KEY NONCLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricGradingScaleHeader] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricGradingScaleHeader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MetricGradingScaleHeader] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricGradingScaleHeader] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricGradingScaleHeader] TO [public]
GO
