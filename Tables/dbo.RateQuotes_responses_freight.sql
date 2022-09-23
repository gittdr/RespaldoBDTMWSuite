CREATE TABLE [dbo].[RateQuotes_responses_freight]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[RateQuoteID] [int] NOT NULL,
[FreightNumber] [int] NULL,
[CommodityCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FreightClass] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Count] [decimal] (18, 0) NULL,
[CountUnits] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Weight] [decimal] (18, 0) NULL,
[WeightUoM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Volume] [decimal] (18, 0) NULL,
[VolumeUoM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FAK] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cost] [decimal] (18, 0) NULL,
[Revenue] [decimal] (18, 0) NULL,
[GrossWeight] [decimal] (18, 0) NULL,
[GrossWeightUoM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GrossVolume] [decimal] (18, 0) NULL,
[GrossVolumeUoM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevFAK] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RateQuotes_responses_freight] ADD CONSTRAINT [RateQuotes_responses_freight_id] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RateQuotes_responses_freight] TO [public]
GO
GRANT INSERT ON  [dbo].[RateQuotes_responses_freight] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RateQuotes_responses_freight] TO [public]
GO
GRANT SELECT ON  [dbo].[RateQuotes_responses_freight] TO [public]
GO
GRANT UPDATE ON  [dbo].[RateQuotes_responses_freight] TO [public]
GO
