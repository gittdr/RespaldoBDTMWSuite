CREATE TABLE [dbo].[ProductTaxDetails]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[CommodityCode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductTaxDetails_CommodityCode] DEFAULT ('UNKNOWN'),
[CommodityClass1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductTaxDetails_CommodityClass1] DEFAULT ('UNKNOWN'),
[CommodityClass2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductTaxDetails_CommodityClass2] DEFAULT ('UNKNOWN'),
[TaxType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Amount] [decimal] (18, 4) NOT NULL CONSTRAINT [DF_ProductTaxDetails_Amount] DEFAULT ((0.0000)),
[StartDate] [datetime] NOT NULL CONSTRAINT [DF_ProductTaxDetails_StartDate] DEFAULT (getdate()),
[EndDate] [datetime] NOT NULL CONSTRAINT [DF_ProductTaxDetails_EndDate] DEFAULT (getdate()),
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductTaxDetails_CreatedDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductTaxDetails_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductTaxDetails] ADD CONSTRAINT [PK_ProductTaxDetails] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductTaxDetails] ADD CONSTRAINT [FK_ProductTaxDetails_ProductTax] FOREIGN KEY ([TaxType]) REFERENCES [dbo].[ProductTax] ([TaxType])
GO
GRANT DELETE ON  [dbo].[ProductTaxDetails] TO [public]
GO
GRANT INSERT ON  [dbo].[ProductTaxDetails] TO [public]
GO
GRANT SELECT ON  [dbo].[ProductTaxDetails] TO [public]
GO
GRANT UPDATE ON  [dbo].[ProductTaxDetails] TO [public]
GO
