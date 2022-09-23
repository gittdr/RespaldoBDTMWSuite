CREATE TABLE [dbo].[golivecheck_fuelimport]
(
[glc_rundate] [datetime] NULL,
[glc_cnt_fuelcards] [int] NULL,
[glc_cnt_acct_code] [int] NULL,
[glc_cnt_cust_code] [int] NULL,
[glc_cnt_payable_no_cards] [int] NULL,
[glc_cnt_fuel_purchases] [int] NULL,
[glc_cnt_fuel_purchase_pyd] [int] NULL,
[glc_cnt_advance_pyd] [int] NULL,
[glc_cnt_payable_drv_no_cards] [int] NULL,
[glc_cnt_payable_trc_no_cards] [int] NULL,
[glc_cnt_cards_no_asset] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[golivecheck_fuelimport] TO [public]
GO
GRANT INSERT ON  [dbo].[golivecheck_fuelimport] TO [public]
GO
GRANT REFERENCES ON  [dbo].[golivecheck_fuelimport] TO [public]
GO
GRANT SELECT ON  [dbo].[golivecheck_fuelimport] TO [public]
GO
GRANT UPDATE ON  [dbo].[golivecheck_fuelimport] TO [public]
GO
