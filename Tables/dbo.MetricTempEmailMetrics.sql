CREATE TABLE [dbo].[MetricTempEmailMetrics]
(
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MetricCode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MetricCaption] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlainDate] [datetime] NULL,
[Result] [decimal] (20, 5) NULL,
[ThisCount] [decimal] (20, 5) NULL,
[ThisTotal] [decimal] (20, 5) NULL,
[MetricTempEmailMetrics_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricTempEmailMetrics] ADD CONSTRAINT [prkey_MetricTempEmailMetrics] PRIMARY KEY CLUSTERED ([MetricTempEmailMetrics_ident]) ON [PRIMARY]
GO
