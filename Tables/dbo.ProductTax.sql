CREATE TABLE [dbo].[ProductTax]
(
[TaxType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BaseTax] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[County] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductTax_CreatedDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductTax_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductTax] ADD CONSTRAINT [PK_ProductTax] PRIMARY KEY CLUSTERED ([TaxType]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ProductTax] TO [public]
GO
GRANT INSERT ON  [dbo].[ProductTax] TO [public]
GO
GRANT SELECT ON  [dbo].[ProductTax] TO [public]
GO
GRANT UPDATE ON  [dbo].[ProductTax] TO [public]
GO
