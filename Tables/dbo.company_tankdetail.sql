CREATE TABLE [dbo].[company_tankdetail]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_tank_id] [int] NOT NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TankSize] [int] NOT NULL,
[Ullage] [int] NOT NULL,
[ShutDownGallons] [int] NOT NULL,
[PMDeliveryPercentage] [decimal] (10, 4) NOT NULL,
[DailyAverageWeeksBack] [int] NOT NULL,
[CompanyType] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__company_t__Compa__2606E819] DEFAULT ('CONS'),
[cmd_class] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[forecast_bucket] [int] NULL,
[Diameter] [decimal] (10, 2) NULL,
[cmd_volumeunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__company_t__cmd_v__7069F177] DEFAULT ('UNK'),
[OrderThreshold] [int] NULL,
[GenerationRule] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__company_t__Gener__715E15B0] DEFAULT ('UNK'),
[PercentOfForecast] [decimal] (9, 2) NULL,
[ForecastID] [int] NULL,
[TankTranslation] [varchar] (19) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[model_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tank_hours_offset] [decimal] (9, 2) NULL,
[ManifoldGroup] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsManifolded] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_company_tankdetail_IsManifolded] DEFAULT ('N'),
[DwellTime] [int] NULL,
[ActiveCommodityCode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ValidCommodityList] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuoteVolume] [int] NOT NULL CONSTRAINT [DF_company_tankdetail_QuoteVolume] DEFAULT ((0)),
[ThresholdPercentofSales] [decimal] (9, 2) NULL,
[IsQuotable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_company_tankdetail_IsQuotable] DEFAULT ('Y'),
[InchesToGallonsFactor] [float] NULL,
[VolumeUnitWeight] [float] NULL,
[IsPumpManifold] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__company_t__IsPum__1C110357] DEFAULT ('N'),
[isproducing] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__company_t__ispro__1D052790] DEFAULT ('Y'),
[cmd_rvp] [float] NULL,
[TankRejected] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__company_t__TankR__1DF94BC9] DEFAULT ('N'),
[LastRejectionDate] [datetime] NULL,
[ctd_identity] [bigint] NOT NULL IDENTITY(1, 1),
[Shrinkage_Incrustation_Factor] [decimal] (7, 3) NULL,
[Meter_Factor] [decimal] (10, 2) NULL,
[Temp_Comp_Meter] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MeterProvingDate] [datetime] NULL,
[dw_timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_tankdetail] ADD CONSTRAINT [PK_CompanyType] PRIMARY KEY CLUSTERED ([cmp_id], [cmp_tank_id], [CompanyType]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [company_tank_key] ON [dbo].[company_tankdetail] ([ctd_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_company_tankdetail_timestamp] ON [dbo].[company_tankdetail] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_company_tankdetail_model_id] ON [dbo].[company_tankdetail] ([model_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_tankdetail] ADD CONSTRAINT [company_tankdetail_model_id_FK] FOREIGN KEY ([model_id]) REFERENCES [dbo].[tankmodel] ([model_id])
GO
GRANT DELETE ON  [dbo].[company_tankdetail] TO [public]
GO
GRANT INSERT ON  [dbo].[company_tankdetail] TO [public]
GO
GRANT SELECT ON  [dbo].[company_tankdetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_tankdetail] TO [public]
GO
