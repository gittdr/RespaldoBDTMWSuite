CREATE TABLE [dbo].[DTNPricingTax]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DTNPricingTax_Shipper] DEFAULT ('UNKNOWN'),
[Supplier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DTNPricingTax_Supplier] DEFAULT ('UNKNOWN'),
[TaxType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsIncluded] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DTNPricingTax_IsIncluded] DEFAULT ('Y'),
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_DTNPricingTax_CreatedDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_DTNPricingTax_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DTNPricingTax] ADD CONSTRAINT [PK_DTNPricingTax] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DTNPricingTax] ADD CONSTRAINT [IX_ShipperSupplierTaxType] UNIQUE NONCLUSTERED ([Shipper], [Supplier], [TaxType]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DTNPricingTax] ADD CONSTRAINT [FK_DTNPricingTax_ProductTax] FOREIGN KEY ([TaxType]) REFERENCES [dbo].[ProductTax] ([TaxType])
GO
GRANT DELETE ON  [dbo].[DTNPricingTax] TO [public]
GO
GRANT INSERT ON  [dbo].[DTNPricingTax] TO [public]
GO
GRANT SELECT ON  [dbo].[DTNPricingTax] TO [public]
GO
GRANT UPDATE ON  [dbo].[DTNPricingTax] TO [public]
GO
