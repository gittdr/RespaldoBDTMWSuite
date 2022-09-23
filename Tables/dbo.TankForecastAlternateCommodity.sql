CREATE TABLE [dbo].[TankForecastAlternateCommodity]
(
[ForecastId] [int] NOT NULL,
[Commodity] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartDate] [datetime] NOT NULL,
[EndDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecastAlternateCommodity] ADD CONSTRAINT [PK_TankForecastAlternateCommodity] PRIMARY KEY CLUSTERED ([ForecastId], [Commodity], [StartDate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TankForecastAlternateCommodity] TO [public]
GO
GRANT INSERT ON  [dbo].[TankForecastAlternateCommodity] TO [public]
GO
GRANT SELECT ON  [dbo].[TankForecastAlternateCommodity] TO [public]
GO
GRANT UPDATE ON  [dbo].[TankForecastAlternateCommodity] TO [public]
GO
