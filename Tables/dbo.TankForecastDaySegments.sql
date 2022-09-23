CREATE TABLE [dbo].[TankForecastDaySegments]
(
[ForecastID] [int] NOT NULL,
[Sequence] [tinyint] NOT NULL,
[Hours] [decimal] (6, 1) NOT NULL,
[Name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PercentOfSales] [decimal] (6, 1) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecastDaySegments] ADD CONSTRAINT [PK_TankForecastDaySegments] PRIMARY KEY CLUSTERED ([ForecastID], [Sequence]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecastDaySegments] ADD CONSTRAINT [FK_TankForecastDaySegments_TankForecast] FOREIGN KEY ([ForecastID]) REFERENCES [dbo].[TankForecast] ([ForecastID])
GO
GRANT DELETE ON  [dbo].[TankForecastDaySegments] TO [public]
GO
GRANT INSERT ON  [dbo].[TankForecastDaySegments] TO [public]
GO
GRANT SELECT ON  [dbo].[TankForecastDaySegments] TO [public]
GO
GRANT UPDATE ON  [dbo].[TankForecastDaySegments] TO [public]
GO
