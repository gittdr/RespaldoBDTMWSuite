CREATE TABLE [dbo].[company_tanksaleshistory]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HistoryDate] [datetime] NOT NULL,
[forecast_bucket] [int] NOT NULL,
[PercentOfForecast] [decimal] (9, 2) NOT NULL,
[ExpectedSales] [int] NOT NULL,
[ExpectedUpdateDate] [datetime] NOT NULL,
[ActualSales] [int] NOT NULL,
[ActualSalesUpdateDate] [datetime] NOT NULL,
[ZeroDate] [datetime] NULL,
[ThresholdDate] [datetime] NULL,
[MaxFill] [int] NULL,
[Reading] [int] NULL,
[ReadingDate] [datetime] NULL,
[InventoryUpdateDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_tanksaleshistory] ADD CONSTRAINT [PK_company_tanksaleshistory] PRIMARY KEY CLUSTERED ([cmp_id], [HistoryDate], [forecast_bucket]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_tanksaleshistory] TO [public]
GO
GRANT INSERT ON  [dbo].[company_tanksaleshistory] TO [public]
GO
GRANT SELECT ON  [dbo].[company_tanksaleshistory] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_tanksaleshistory] TO [public]
GO
