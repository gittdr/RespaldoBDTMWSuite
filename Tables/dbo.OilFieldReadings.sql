CREATE TABLE [dbo].[OilFieldReadings]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[inv_tankID] [int] NULL,
[fgt_number] [int] NULL,
[inv_value] [decimal] (8, 2) NULL,
[inv_readingdate] [datetime] NOT NULL,
[ord_hdrnumber] [int] NULL,
[run_ticket] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ofr_topgaugemeasurement] [decimal] (8, 2) NULL,
[inv_gravity] [float] NULL,
[inv_BSW] [float] NULL,
[inv_temperature] [decimal] (6, 2) NULL,
[inv_observedtemperature] [decimal] (6, 2) NULL,
[inv_seal_on] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[inv_seal_ondate] [datetime] NOT NULL,
[inv_seal_off] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[inv_seal_offdate] [datetime] NOT NULL,
[ofr_bottomgaugemeasurement] [decimal] (8, 2) NULL,
[ofr_meterstart] [decimal] (14, 6) NULL,
[ofr_meterend] [decimal] (14, 6) NULL,
[tank_producing] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ofr_topgauge2measurement] [decimal] (8, 2) NULL,
[ofr_apigravity] [float] NULL,
[ofr_bottomtemp] [decimal] (6, 2) NULL,
[ofr_BSWHeight] [decimal] (8, 2) NULL,
[OpenDateTime] [datetime] NULL,
[CloseDateTime] [datetime] NULL,
[AvgLineTemp] [decimal] (6, 2) NULL,
[DeliveryStartMeter] [decimal] (10, 3) NULL,
[DeliveryEndMeter] [decimal] (10, 3) NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDateTime] [datetime] NULL,
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedDateTime] [datetime] NULL,
[ofr_bottomgauge2measurement] [decimal] (8, 2) NULL,
[RefusalReason] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefusalType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TicketType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BottomScaleFactorUom] [decimal] (10, 4) NULL,
[Bottom2ScaleFactorUom] [decimal] (10, 4) NULL,
[TopScaleFactorUom] [decimal] (10, 4) NULL,
[Top2ScaleFactorUom] [decimal] (10, 4) NULL,
[MeterFactor] [decimal] (10, 4) NULL,
[IsTopOff] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_OilFieldReadings_IsTopOff] DEFAULT ('N'),
[Comments] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dw_timestamp] [timestamp] NOT NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__OilFieldR__INS_T__61DB3913] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OilFieldReadings] ADD CONSTRAINT [pk_OilFieldReadings] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_OilFieldReadings_date_cmp_tank] ON [dbo].[OilFieldReadings] ([cmp_id], [inv_readingdate], [inv_tankID]) INCLUDE ([inv_value], [ofr_topgaugemeasurement], [ofr_bottomgaugemeasurement]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_OilFieldReadings_cmp_tank_date] ON [dbo].[OilFieldReadings] ([cmp_id], [inv_tankID], [inv_readingdate]) INCLUDE ([inv_value], [ofr_topgaugemeasurement], [ofr_bottomgaugemeasurement]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_oilfieldreadings_timestamp] ON [dbo].[OilFieldReadings] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_OilFieldReadings_fgt_number_date_tank] ON [dbo].[OilFieldReadings] ([fgt_number], [inv_readingdate], [inv_tankID]) INCLUDE ([inv_value], [cmp_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_OilFieldReadings_fgt_number_tank_date] ON [dbo].[OilFieldReadings] ([fgt_number], [inv_tankID], [inv_readingdate]) INCLUDE ([inv_value], [cmp_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [OilFieldReadings_INS_TIMESTAMP] ON [dbo].[OilFieldReadings] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_OilFieldReadings_readingdate] ON [dbo].[OilFieldReadings] ([inv_readingdate]) INCLUDE ([cmp_id], [inv_tankID], [inv_value], [ofr_topgaugemeasurement], [ofr_bottomgaugemeasurement]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_OilFieldReadings_run_ticket] ON [dbo].[OilFieldReadings] ([run_ticket]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OilFieldReadings] TO [public]
GO
GRANT INSERT ON  [dbo].[OilFieldReadings] TO [public]
GO
GRANT REFERENCES ON  [dbo].[OilFieldReadings] TO [public]
GO
GRANT SELECT ON  [dbo].[OilFieldReadings] TO [public]
GO
GRANT UPDATE ON  [dbo].[OilFieldReadings] TO [public]
GO
