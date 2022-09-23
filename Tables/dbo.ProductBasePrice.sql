CREATE TABLE [dbo].[ProductBasePrice]
(
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[Shipper] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductBasePrice_Shipper] DEFAULT ('UNKNOWN'),
[Supplier] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductBasePrice_Supplier] DEFAULT ('UNKNOWN'),
[CommodityCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductBasePrice_Commodity] DEFAULT ('UNKNOWN'),
[PriceDate] [datetime] NOT NULL CONSTRAINT [DF_ProductBasePrice_PriceDate] DEFAULT (getdate()),
[Price] [decimal] (18, 4) NOT NULL CONSTRAINT [DF_ProductBasePrice_Price] DEFAULT ((0.00)),
[Comment] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductBasePrice_CreatedDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductBasePrice_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductBasePrice] ADD CONSTRAINT [PK_ProductPricingNormal] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductBasePrice] ADD CONSTRAINT [IX_ProductPricingNormal] UNIQUE NONCLUSTERED ([Price], [CommodityCode], [PriceDate], [Shipper], [Supplier]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ProductBasePrice] TO [public]
GO
GRANT INSERT ON  [dbo].[ProductBasePrice] TO [public]
GO
GRANT SELECT ON  [dbo].[ProductBasePrice] TO [public]
GO
GRANT UPDATE ON  [dbo].[ProductBasePrice] TO [public]
GO
