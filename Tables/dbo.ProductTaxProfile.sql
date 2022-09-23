CREATE TABLE [dbo].[ProductTaxProfile]
(
[TaxType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AmountType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Amount] [decimal] (18, 4) NOT NULL CONSTRAINT [DF_ProductTaxProfile_Amount] DEFAULT ((0.0000)),
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductTaxProfile_CreatedDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductTaxProfile_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductTaxProfile] ADD CONSTRAINT [PK_ProductTaxProfile] PRIMARY KEY CLUSTERED ([TaxType]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ProductTaxProfile] TO [public]
GO
GRANT INSERT ON  [dbo].[ProductTaxProfile] TO [public]
GO
GRANT SELECT ON  [dbo].[ProductTaxProfile] TO [public]
GO
GRANT UPDATE ON  [dbo].[ProductTaxProfile] TO [public]
GO
