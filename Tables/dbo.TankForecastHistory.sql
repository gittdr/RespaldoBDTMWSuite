CREATE TABLE [dbo].[TankForecastHistory]
(
[ForecastId] [int] NOT NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ForecastDate] [datetime] NOT NULL,
[ForecastAverageSales] [int] NOT NULL,
[ForecastAverageSalesUpdateDate] [datetime] NOT NULL,
[AdjustType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AdjustAmount] [decimal] (9, 2) NOT NULL,
[AdjustAmountUpdateDate] [datetime] NOT NULL,
[AdjustAmountUpdateBy] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
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
ALTER TABLE [dbo].[TankForecastHistory] ADD CONSTRAINT [PK_TankForecastHistory] PRIMARY KEY CLUSTERED ([cmp_id], [ForecastDate], [ForecastId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TankForecastHistory] TO [public]
GO
GRANT INSERT ON  [dbo].[TankForecastHistory] TO [public]
GO
GRANT SELECT ON  [dbo].[TankForecastHistory] TO [public]
GO
GRANT UPDATE ON  [dbo].[TankForecastHistory] TO [public]
GO
