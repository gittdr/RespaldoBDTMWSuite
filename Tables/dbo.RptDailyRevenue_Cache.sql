CREATE TABLE [dbo].[RptDailyRevenue_Cache]
(
[metriccode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[plaindate] [datetime] NOT NULL,
[OrderNumber] [int] NULL,
[InvoiceNumber] [int] NULL,
[Revenue] [money] NULL,
[RevenueSource] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevenueDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RptDailyRevenue_Cache] ADD CONSTRAINT [AutoPK_RptDailyRevenue_Cache_metriccode_PlainDate] PRIMARY KEY CLUSTERED ([metriccode], [plaindate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxRptDailyRevenueCache] ON [dbo].[RptDailyRevenue_Cache] ([metriccode], [plaindate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RptDailyRevenue_Cache] TO [public]
GO
GRANT INSERT ON  [dbo].[RptDailyRevenue_Cache] TO [public]
GO
GRANT SELECT ON  [dbo].[RptDailyRevenue_Cache] TO [public]
GO
GRANT UPDATE ON  [dbo].[RptDailyRevenue_Cache] TO [public]
GO
