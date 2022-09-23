CREATE TABLE [dbo].[TankForecastLogHourly]
(
[LogId] [int] NOT NULL,
[HourOffset] [int] NOT NULL,
[Reading1] [int] NOT NULL,
[Reading2] [int] NOT NULL,
[Reading3] [int] NOT NULL,
[Reading4] [int] NOT NULL,
[Reading5] [int] NOT NULL,
[Reading6] [int] NOT NULL,
[Reading7] [int] NOT NULL,
[Reading8] [int] NOT NULL,
[Reading9] [int] NOT NULL,
[Reading10] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecastLogHourly] ADD CONSTRAINT [pk_TankForecastLogHourly] PRIMARY KEY CLUSTERED ([LogId], [HourOffset]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecastLogHourly] ADD CONSTRAINT [FK_TankForecastLogHourly_LogId] FOREIGN KEY ([LogId]) REFERENCES [dbo].[TankForecastLog] ([LogId])
GO
GRANT DELETE ON  [dbo].[TankForecastLogHourly] TO [public]
GO
GRANT INSERT ON  [dbo].[TankForecastLogHourly] TO [public]
GO
GRANT SELECT ON  [dbo].[TankForecastLogHourly] TO [public]
GO
GRANT UPDATE ON  [dbo].[TankForecastLogHourly] TO [public]
GO
