CREATE TABLE [dbo].[MetricDetailInfo]
(
[MetricCode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PlainDate] [datetime] NOT NULL,
[MetricItem] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricDetailInfo] ADD CONSTRAINT [AutoPK_MetricDetailInfo_MetricCode_PlainDate_MetricItem] PRIMARY KEY CLUSTERED ([MetricCode], [PlainDate], [MetricItem]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricDetailInfo] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricDetailInfo] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricDetailInfo] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricDetailInfo] TO [public]
GO
