CREATE TABLE [dbo].[TankForecastCommonLoads]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Abbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Volume1] [int] NOT NULL CONSTRAINT [dk_TankForecastCommonLoads_volume1] DEFAULT ((0)),
[Volume2] [int] NOT NULL CONSTRAINT [dk_TankForecastCommonLoads_volume2] DEFAULT ((0)),
[Volume3] [int] NOT NULL CONSTRAINT [dk_TankForecastCommonLoads_volume3] DEFAULT ((0)),
[Volume4] [int] NOT NULL CONSTRAINT [dk_TankForecastCommonLoads_volume4] DEFAULT ((0)),
[Volume5] [int] NOT NULL CONSTRAINT [dk_TankForecastCommonLoads_volume5] DEFAULT ((0)),
[SpecificGravity1] [decimal] (9, 4) NOT NULL CONSTRAINT [dk_TankForecastCommonLoads_SpecificGravity1] DEFAULT ((0)),
[SpecificGravity2] [decimal] (9, 4) NOT NULL CONSTRAINT [dk_TankForecastCommonLoads_SpecificGravity2] DEFAULT ((0)),
[SpecificGravity3] [decimal] (9, 4) NOT NULL CONSTRAINT [dk_TankForecastCommonLoads_SpecificGravity3] DEFAULT ((0)),
[SpecificGravity4] [decimal] (9, 4) NOT NULL CONSTRAINT [dk_TankForecastCommonLoads_SpecificGravity4] DEFAULT ((0)),
[SpecificGravity5] [decimal] (9, 4) NOT NULL CONSTRAINT [dk_TankForecastCommonLoads_SpecificGravity5] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecastCommonLoads] ADD CONSTRAINT [pk_TankForecastCommonLoads_ID] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TankForecastCommonLoads] TO [public]
GO
GRANT INSERT ON  [dbo].[TankForecastCommonLoads] TO [public]
GO
GRANT SELECT ON  [dbo].[TankForecastCommonLoads] TO [public]
GO
GRANT UPDATE ON  [dbo].[TankForecastCommonLoads] TO [public]
GO
