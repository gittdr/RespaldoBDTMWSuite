CREATE TABLE [dbo].[Fuel_prefered_vendor_rates]
(
[fpv_id] [int] NOT NULL IDENTITY(1, 1),
[fpv_chain] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fpv_rate] [numeric] (18, 2) NULL,
[fpv_effective] [datetime] NOT NULL,
[fpv_expires] [datetime] NOT NULL,
[fpv_comments] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Fuel_prefered_vendor_rates] TO [public]
GO
GRANT INSERT ON  [dbo].[Fuel_prefered_vendor_rates] TO [public]
GO
GRANT SELECT ON  [dbo].[Fuel_prefered_vendor_rates] TO [public]
GO
GRANT UPDATE ON  [dbo].[Fuel_prefered_vendor_rates] TO [public]
GO
