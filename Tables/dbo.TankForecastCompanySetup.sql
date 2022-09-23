CREATE TABLE [dbo].[TankForecastCompanySetup]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadsToForecast] [int] NOT NULL,
[MaxCommoditiesPerLoad] [int] NOT NULL,
[TargetDeliveryWindowHrs] [int] NOT NULL,
[FullTrailerAmount] [int] NOT NULL,
[TriggerCommodity] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TriggerAmount] [int] NOT NULL,
[DefaultShipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultSupplier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultAccountOf] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Commodity1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Amount1] [int] NOT NULL,
[TargetOnHandAmount1] [int] NOT NULL,
[Commodity2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Amount2] [int] NOT NULL,
[TargetOnHandAmount2] [int] NOT NULL,
[Commodity3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Amount3] [int] NOT NULL,
[TargetOnHandAmount3] [int] NOT NULL,
[Commodity4] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Amount4] [int] NOT NULL,
[TargetOnHandAmount4] [int] NOT NULL,
[SpecificGravity] [decimal] (9, 4) NULL,
[MaxVolume2Compartments] [int] NULL,
[ShortLoadThreshold] [int] NULL,
[CommonLoadAbbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_TankForecastCompanySetup_CommonLoadAbbr] DEFAULT ('UNK'),
[ForecastSplitGroup] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_TankForecastCompanySetup_ForecastSplitGroup] DEFAULT ('UNK')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecastCompanySetup] ADD CONSTRAINT [PK__TankForecastComp__10D6C109] PRIMARY KEY CLUSTERED ([cmp_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_TankForecastCompanySetup_ForecastSplitGroup] ON [dbo].[TankForecastCompanySetup] ([ForecastSplitGroup]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecastCompanySetup] ADD CONSTRAINT [FK_TankForecastCompanySetup_cmp_id] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[company] ([cmp_id])
GO
GRANT DELETE ON  [dbo].[TankForecastCompanySetup] TO [public]
GO
GRANT INSERT ON  [dbo].[TankForecastCompanySetup] TO [public]
GO
GRANT SELECT ON  [dbo].[TankForecastCompanySetup] TO [public]
GO
GRANT UPDATE ON  [dbo].[TankForecastCompanySetup] TO [public]
GO
