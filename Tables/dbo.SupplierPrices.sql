CREATE TABLE [dbo].[SupplierPrices]
(
[Supplier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SupplierPrices_Shipper] DEFAULT ('UNKNOWN'),
[CommodityCode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_SupplierPrices_EffectiveDate] DEFAULT (getdate()),
[EffectivePrice] [decimal] (18, 3) NOT NULL CONSTRAINT [DF_SupplierPrices_EffectivePrice] DEFAULT ((0.0)),
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_SupplierPrices_CreatedDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SupplierPrices_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupplierPrices] ADD CONSTRAINT [PK_SupplierPrices] PRIMARY KEY CLUSTERED ([Supplier], [CommodityCode], [EffectiveDate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SupplierPrices] TO [public]
GO
GRANT INSERT ON  [dbo].[SupplierPrices] TO [public]
GO
GRANT SELECT ON  [dbo].[SupplierPrices] TO [public]
GO
GRANT UPDATE ON  [dbo].[SupplierPrices] TO [public]
GO
