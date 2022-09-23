CREATE TABLE [dbo].[TankForecast]
(
[ForecastID] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ForecastType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CommodityString] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AverageWeeklySales] [int] NOT NULL,
[WeeksInAverage] [int] NOT NULL,
[Last7DaySales] [int] NOT NULL,
[AutoAdjustLastRunDate] [datetime] NULL,
[Generation_ord_hdrnumber] [int] NOT NULL,
[AuditRule] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TankForec__Audit__7DC3EC95] DEFAULT ('5SL1TK'),
[inv_readingdate2] [datetime] NULL,
[inv_readingdate3] [datetime] NULL,
[inv_readingdate4] [datetime] NULL,
[inv_readingdate5] [datetime] NULL,
[inv_readingdate6] [datetime] NULL,
[Commodity_EqId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecast] ADD CONSTRAINT [PK_TankForecast] PRIMARY KEY CLUSTERED ([ForecastID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecast] ADD CONSTRAINT [FK_TankForecast_cmp_id] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[company] ([cmp_id])
GO
GRANT DELETE ON  [dbo].[TankForecast] TO [public]
GO
GRANT INSERT ON  [dbo].[TankForecast] TO [public]
GO
GRANT SELECT ON  [dbo].[TankForecast] TO [public]
GO
GRANT UPDATE ON  [dbo].[TankForecast] TO [public]
GO
