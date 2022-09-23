CREATE TABLE [dbo].[cdfuelbill_pricecap]
(
[cdp_id] [int] NOT NULL IDENTITY(1, 1),
[cdp_vendor] [int] NOT NULL,
[cdp_company] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cdp_terminal] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cdp_network_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cdp_metric_admin_fee] [money] NOT NULL,
[cdp_us_admin_fee] [money] NOT NULL,
[cdp_metric_price_cap] [money] NOT NULL,
[cdp_us_price_cap] [money] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdfuelbill_pricecap] ADD CONSTRAINT [pk_cdfuelbill_pricecap] PRIMARY KEY CLUSTERED ([cdp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cdfuelbill_pricecap] TO [public]
GO
GRANT INSERT ON  [dbo].[cdfuelbill_pricecap] TO [public]
GO
GRANT SELECT ON  [dbo].[cdfuelbill_pricecap] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdfuelbill_pricecap] TO [public]
GO
