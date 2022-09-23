CREATE TABLE [dbo].[TMSEDI204Cargo]
(
[CargoId] [int] NOT NULL IDENTITY(1, 1),
[StopId] [int] NOT NULL,
[Version] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuantityUnit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WeightUnit] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Weight] [decimal] (10, 2) NULL,
[VolumeUnit] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Volume] [decimal] (10, 2) NULL,
[RateUnit] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rate] [decimal] (10, 2) NULL,
[ChargeCurrencey] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Charge] [decimal] (10, 2) NULL,
[Commodity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CommodityCode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[length] [decimal] (8, 2) NULL,
[lengthUnit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Width] [decimal] (8, 2) NULL,
[WidthUnit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Height] [decimal] (8, 2) NULL,
[HeightUnit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Quantity2Units] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Quantity2] [decimal] (10, 2) NULL,
[EDICommodityCode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Quantity] [decimal] (10, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSEDI204Cargo] ADD CONSTRAINT [PK_TMSEDI204Cargos] PRIMARY KEY CLUSTERED ([CargoId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSEDI204Cargo] ADD CONSTRAINT [FK_TMSEDI204Cargo_TMSEDI204Stops] FOREIGN KEY ([StopId]) REFERENCES [dbo].[TMSEDI204Stops] ([StopId])
GO
GRANT DELETE ON  [dbo].[TMSEDI204Cargo] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSEDI204Cargo] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSEDI204Cargo] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSEDI204Cargo] TO [public]
GO
