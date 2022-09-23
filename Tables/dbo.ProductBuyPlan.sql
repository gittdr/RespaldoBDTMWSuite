CREATE TABLE [dbo].[ProductBuyPlan]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Consignee] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Supplier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AccountOf] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Tank_cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsActive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductBuyPlan_IsActive] DEFAULT ('Y'),
[SplashFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductBuyPlan_SplashFlag] DEFAULT ('N'),
[ProductRetail] [decimal] (18, 6) NOT NULL,
[ProductCost] [decimal] (18, 6) NOT NULL,
[ProductRank] [int] NOT NULL,
[ProductPriceDate] [datetime] NOT NULL,
[MinLoadCount] [int] NOT NULL,
[MaxLoadCount] [int] NOT NULL,
[TargetLoadCount] [int] NOT NULL,
[CreatedBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductBuyPlan_CreatedDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductBuyPlan_ModifiedDate] DEFAULT (getdate()),
[QuotePrice] [decimal] (18, 4) NOT NULL CONSTRAINT [dk_ProductBuyPlan_QuotePrice] DEFAULT ((0)),
[IsQuote] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_ProductBuyPlan_IsQuote] DEFAULT ('N'),
[Transportation] [decimal] (18, 4) NOT NULL CONSTRAINT [dk_ProductBuyPlan_Transportation] DEFAULT ((0)),
[RawPrice] [decimal] (18, 4) NOT NULL CONSTRAINT [dk_ProductBuyPlan_RawPrice] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductBuyPlan] ADD CONSTRAINT [PK_ProductBuyPlan_ID] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_ProductBuyPlan_Consignee_IsActive] ON [dbo].[ProductBuyPlan] ([Consignee], [IsActive]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ProductBuyPlan] TO [public]
GO
GRANT INSERT ON  [dbo].[ProductBuyPlan] TO [public]
GO
GRANT SELECT ON  [dbo].[ProductBuyPlan] TO [public]
GO
GRANT UPDATE ON  [dbo].[ProductBuyPlan] TO [public]
GO
