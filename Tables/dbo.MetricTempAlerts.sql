CREATE TABLE [dbo].[MetricTempAlerts]
(
[result] [int] NULL,
[MetricTempAlerts_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricTempAlerts] ADD CONSTRAINT [prkey_MetricTempAlerts] PRIMARY KEY CLUSTERED ([MetricTempAlerts_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricTempAlerts] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricTempAlerts] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricTempAlerts] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricTempAlerts] TO [public]
GO
