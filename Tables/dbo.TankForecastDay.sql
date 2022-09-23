CREATE TABLE [dbo].[TankForecastDay]
(
[ForecastID] [int] NOT NULL,
[DayNumber] [tinyint] NOT NULL,
[PercentOfSales] [decimal] (6, 1) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecastDay] ADD CONSTRAINT [PK_TankForecastDay] PRIMARY KEY CLUSTERED ([ForecastID], [DayNumber]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecastDay] ADD CONSTRAINT [FK_TankForecastDay_TankForecast] FOREIGN KEY ([ForecastID]) REFERENCES [dbo].[TankForecast] ([ForecastID])
GO
GRANT DELETE ON  [dbo].[TankForecastDay] TO [public]
GO
GRANT INSERT ON  [dbo].[TankForecastDay] TO [public]
GO
GRANT SELECT ON  [dbo].[TankForecastDay] TO [public]
GO
GRANT UPDATE ON  [dbo].[TankForecastDay] TO [public]
GO
