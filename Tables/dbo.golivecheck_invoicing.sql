CREATE TABLE [dbo].[golivecheck_invoicing]
(
[glc_rundate] [datetime] NULL,
[glc_cnt_ivh_selection] [int] NULL,
[glc_cnt_invoices] [int] NULL,
[glc_cnt_active_cht] [int] NULL,
[glc_pct_active_cht_nogl] [float] NULL,
[glc_cnt_misc_inv] [int] NULL,
[glc_cnt_supp_inv] [int] NULL,
[glc_cnt_prn_inv] [int] NULL,
[glc_cnt_xfr_inv] [int] NULL,
[glc_pct_auto_rated_inv] [float] NULL,
[glc_cnt_prn_mb] [int] NULL,
[glc_cnt_inv_thrty] [int] NULL,
[glc_cnt_inv_ninty] [int] NULL,
[glc_cnt_inv_cm_rb] [int] NULL,
[glc_pct_inv_mult_acc] [float] NULL,
[glc_pct_inv_autorated] [float] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[golivecheck_invoicing] TO [public]
GO
GRANT INSERT ON  [dbo].[golivecheck_invoicing] TO [public]
GO
GRANT REFERENCES ON  [dbo].[golivecheck_invoicing] TO [public]
GO
GRANT SELECT ON  [dbo].[golivecheck_invoicing] TO [public]
GO
GRANT UPDATE ON  [dbo].[golivecheck_invoicing] TO [public]
GO
