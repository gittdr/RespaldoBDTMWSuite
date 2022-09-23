CREATE TABLE [dbo].[MetricTempIDs]
(
[MetricItem] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MetricTempIDs_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricTempIDs] ADD CONSTRAINT [prkey_MetricTempIDs] PRIMARY KEY CLUSTERED ([MetricTempIDs_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricTempIDs] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricTempIDs] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricTempIDs] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricTempIDs] TO [public]
GO
