CREATE TABLE [dbo].[golivecheck_filemaint]
(
[glc_rundate] [datetime] NULL,
[glc_pct_cty_valid_reg1] [float] NULL,
[glc_cnt_company] [int] NULL,
[glc_cnt_nonimp_company] [int] NULL,
[glc_cnt_act_drv] [int] NULL,
[glc_cnt_manual_drv] [int] NULL,
[glc_cnt_act_trc] [int] NULL,
[glc_cnt_manual_trc] [int] NULL,
[glc_cnt_pr_trc] [int] NULL,
[glc_cnt_ap_no_payto_trc] [int] NULL,
[glc_cnt_act_trl] [int] NULL,
[glc_cnt_act_payto] [int] NULL,
[glc_cnt_orph_payto] [int] NULL,
[glc_cnt_act_car] [int] NULL,
[glc_cnt_no_acct_car] [int] NULL,
[glc_cnt_glreset] [int] NULL,
[glc_cnt_pyd_gl] [int] NULL,
[glc_cnt_inv_gl] [int] NULL,
[glc_cnt_badzip_company] [int] NULL,
[glc_cnt_act_billto_company] [int] NULL,
[glc_cnt_company_directions] [int] NULL,
[glc_cnt_ap_drv] [int] NULL,
[glc_cnt_ap_drv_no_payto] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[golivecheck_filemaint] TO [public]
GO
GRANT INSERT ON  [dbo].[golivecheck_filemaint] TO [public]
GO
GRANT REFERENCES ON  [dbo].[golivecheck_filemaint] TO [public]
GO
GRANT SELECT ON  [dbo].[golivecheck_filemaint] TO [public]
GO
GRANT UPDATE ON  [dbo].[golivecheck_filemaint] TO [public]
GO
