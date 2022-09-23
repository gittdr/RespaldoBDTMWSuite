CREATE TABLE [dbo].[DTNPricing]
(
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[Shipper] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DTNPricing_Shipper] DEFAULT ('UNKNOWN'),
[Supplier] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DTNPricing_Supplier] DEFAULT ('UNKNOWN'),
[CommodityCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Table_1_Commodity] DEFAULT ('UNKNOWN'),
[PriceDate] [datetime] NOT NULL CONSTRAINT [DF_DTNPricing_PriceDate] DEFAULT (getdate()),
[Price] [decimal] (18, 4) NOT NULL CONSTRAINT [DF_DTNPricing_Price] DEFAULT ((0.00)),
[Delta] [decimal] (18, 4) NOT NULL CONSTRAINT [DF_DTNPricing_Delta] DEFAULT ((0.00)),
[PriceSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DTNPricing_PriceSource] DEFAULT ('UNK'),
[CreatedBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_DTNPricing_CreatedDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_DTNPricing_ModifiedDate] DEFAULT (getdate()),
[AccountOf] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DTNPricing_AccountOf] DEFAULT ('UNKNOWN')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DTNPricing] ADD CONSTRAINT [PK_DTNPricing] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DTNPricing] ADD CONSTRAINT [IX_DTNPricing] UNIQUE NONCLUSTERED ([Price], [CommodityCode], [PriceDate], [Shipper], [Supplier], [AccountOf]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DTNPricing] TO [public]
GO
GRANT INSERT ON  [dbo].[DTNPricing] TO [public]
GO
GRANT SELECT ON  [dbo].[DTNPricing] TO [public]
GO
GRANT UPDATE ON  [dbo].[DTNPricing] TO [public]
GO
