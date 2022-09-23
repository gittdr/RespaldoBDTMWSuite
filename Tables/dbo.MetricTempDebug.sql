CREATE TABLE [dbo].[MetricTempDebug]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[sText] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spid] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricTempDebug] ADD CONSTRAINT [AutoPK_MetricTempDebug_SN] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricTempDebug] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricTempDebug] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricTempDebug] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricTempDebug] TO [public]
GO
