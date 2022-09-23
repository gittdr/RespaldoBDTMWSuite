CREATE TABLE [dbo].[ProductPrice]
(
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[Shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductPrice_Shipper] DEFAULT ('UNKNOWN'),
[Supplier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductPrice_Supplier] DEFAULT ('UNKNOWN'),
[AccountOf] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductPrice_AccountOf] DEFAULT ('UNKNOWN'),
[Consignee] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductPrice_Consignee] DEFAULT ('UNKNOWN'),
[CommodityCode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductPrice_CommodityCode] DEFAULT ('UNKNOWN'),
[PriceSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductPrice_PriceSource] DEFAULT ('UNK'),
[Price] [decimal] (18, 4) NOT NULL CONSTRAINT [DF_ProductPrice_Price] DEFAULT ((0.00)),
[EffectiveStartDate] [datetime] NOT NULL CONSTRAINT [DF_ProductPrice_EffectiveStartDate] DEFAULT (getdate()),
[EffectiveEndDate] [datetime] NOT NULL CONSTRAINT [DF_ProductPrice_EffectiveEndDate] DEFAULT ('12/31/2049'),
[Overhead] [decimal] (18, 4) NOT NULL CONSTRAINT [DF_ProductPrice_Overhead] DEFAULT ((0.00)),
[ProductTaxes] [decimal] (18, 4) NOT NULL CONSTRAINT [DF_ProductPrice_ProductTaxes] DEFAULT ((0.00)),
[CompanyTaxes] [decimal] (18, 4) NOT NULL CONSTRAINT [DF_ProductPrice_CompanyTaxes] DEFAULT ((0.00)),
[TotalMarkups] [decimal] (18, 4) NOT NULL CONSTRAINT [DF_ProductPrice_TotalMarkups] DEFAULT ((0.00)),
[Transportation] [decimal] (18, 4) NOT NULL CONSTRAINT [DF_ProductPrice_Transportation] DEFAULT ((0.00)),
[IsActive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductPrice_IsActive] DEFAULT ('Y'),
[CreatedBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductPrice_CreatedDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductPrice_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductPrice] ADD CONSTRAINT [PK_ProductPrice] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_ProductPrice_Consignee_EffectiveStartDate_EffectiveEndDate] ON [dbo].[ProductPrice] ([Consignee], [EffectiveStartDate], [EffectiveEndDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductPrice] ADD CONSTRAINT [IX_ProductPrice] UNIQUE NONCLUSTERED ([IsActive], [Shipper], [Supplier], [AccountOf], [Consignee], [CommodityCode], [EffectiveStartDate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ProductPrice] TO [public]
GO
GRANT INSERT ON  [dbo].[ProductPrice] TO [public]
GO
GRANT SELECT ON  [dbo].[ProductPrice] TO [public]
GO
GRANT UPDATE ON  [dbo].[ProductPrice] TO [public]
GO
