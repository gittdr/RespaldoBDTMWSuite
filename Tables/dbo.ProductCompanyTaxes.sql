CREATE TABLE [dbo].[ProductCompanyTaxes]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[CompanyTaxGroup] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductCompanyTaxes_CompanyTaxGroup] DEFAULT ('UNKNOWN'),
[ProductTaxGroup] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductCompanyTaxes_ProductTaxGroup] DEFAULT ('UNK'),
[TaxType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductCompanyTaxes_TaxType] DEFAULT ('UNKNOWN'),
[ApplyOrder] [int] NOT NULL CONSTRAINT [DF_ProductCompanyTaxes_ApplyOrder] DEFAULT ((0)),
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductCompanyTaxes_CreatedDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductCompanyTaxes_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductCompanyTaxes] ADD CONSTRAINT [PK_ProductCompanyTaxes] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductCompanyTaxes] ADD CONSTRAINT [IX_ProductCompanyTaxes] UNIQUE NONCLUSTERED ([CompanyTaxGroup], [ProductTaxGroup], [TaxType]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ProductCompanyTaxes] TO [public]
GO
GRANT INSERT ON  [dbo].[ProductCompanyTaxes] TO [public]
GO
GRANT SELECT ON  [dbo].[ProductCompanyTaxes] TO [public]
GO
GRANT UPDATE ON  [dbo].[ProductCompanyTaxes] TO [public]
GO
