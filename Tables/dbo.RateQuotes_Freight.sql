CREATE TABLE [dbo].[RateQuotes_Freight]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[RateQuoteID] [int] NOT NULL,
[CommodityCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FreightClass] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Count] [decimal] (18, 0) NULL,
[CountUnits] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Volume] [decimal] (18, 0) NULL,
[VolumeUnits] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Weight] [decimal] (18, 0) NULL,
[WeightUnits] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RateQuotes_Freight] TO [public]
GO
GRANT INSERT ON  [dbo].[RateQuotes_Freight] TO [public]
GO
GRANT SELECT ON  [dbo].[RateQuotes_Freight] TO [public]
GO
GRANT UPDATE ON  [dbo].[RateQuotes_Freight] TO [public]
GO
