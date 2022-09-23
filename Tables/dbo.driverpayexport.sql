CREATE TABLE [dbo].[driverpayexport]
(
[dpe_number] [int] NOT NULL,
[ivh_invoicenumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_driver] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_company] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_division] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_fleet] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_firstname] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_lastname] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_middlename] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_billdate] [datetime] NULL,
[ivh_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_shipdate] [datetime] NULL,
[ivh_shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_name_shipper] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_name_shipper] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_state_shipper] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_deliverydate] [datetime] NULL,
[ivh_consignee] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_name_consignee] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_name_consignee] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_state_consignee] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_charge] [money] NULL,
[pyr_ratecode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_quantity] [float] NULL,
[pyd_rate] [money] NULL,
[pyd_amount] [money] NULL,
[pyd_glnum] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_currencydate] [datetime] NULL,
[pyd_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_refnumtype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_pr_glnum] [char] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_pretax] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_name_billto] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_name_billto] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_state_billto] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_transferdate] [datetime] NULL,
[pyd_exportstatus] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_number] [int] NULL,
[mov_number] [int] NULL,
[lgh_number] [int] NULL,
[dpe_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[driverpayexport] TO [public]
GO
GRANT INSERT ON  [dbo].[driverpayexport] TO [public]
GO
GRANT REFERENCES ON  [dbo].[driverpayexport] TO [public]
GO
GRANT SELECT ON  [dbo].[driverpayexport] TO [public]
GO
GRANT UPDATE ON  [dbo].[driverpayexport] TO [public]
GO
