CREATE TABLE [dbo].[RateQuotes_Responses]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[RateQuoteID] [int] NOT NULL,
[Source] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CarrierID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CostRateID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CostRateDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StrategyId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TierId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalCost] [decimal] (18, 0) NULL,
[RevenueRateID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevenueRateDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevStrategyId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevTierId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalRevenue] [decimal] (18, 0) NULL,
[DeliveryDate] [date] NULL,
[LineHaulNet] [decimal] (18, 2) NULL,
[TotalAccessorial] [decimal] (18, 2) NULL,
[LineHaulGross] [decimal] (18, 2) NULL,
[TariffDiscount] [decimal] (18, 2) NULL,
[TariffDiscountPercent] [decimal] (18, 2) NULL,
[StrategyDiscount] [decimal] (18, 2) NULL,
[StrategyMarkup] [decimal] (18, 2) NULL,
[TmsMarkupPercent] [decimal] (18, 2) NULL,
[Mode] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceDays] [int] NULL,
[IsDirect] [bit] NOT NULL,
[CostRatingType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevenueRatingType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevLineHaulNet] [decimal] (18, 2) NULL,
[RevTotalAccessorial] [decimal] (18, 2) NULL,
[RevLineHaulGross] [decimal] (18, 2) NULL,
[RevTariffDiscount] [decimal] (18, 2) NULL,
[RevTariffDiscountPercent] [decimal] (18, 2) NULL,
[RevStrategyDiscount] [decimal] (18, 2) NULL,
[RevStrategyMarkup] [decimal] (18, 2) NULL,
[ContractUse] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsHouseCarrier] [bit] NULL,
[RevContractUse] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevIsHouseCarrier] [bit] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RateQuotes_Responses] TO [public]
GO
GRANT INSERT ON  [dbo].[RateQuotes_Responses] TO [public]
GO
GRANT SELECT ON  [dbo].[RateQuotes_Responses] TO [public]
GO
GRANT UPDATE ON  [dbo].[RateQuotes_Responses] TO [public]
GO
