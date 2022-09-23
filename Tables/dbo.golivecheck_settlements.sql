CREATE TABLE [dbo].[golivecheck_settlements]
(
[glc_rundate] [datetime] NULL,
[glc_cnt_payheader] [int] NULL,
[glc_cnt_future_payperiod] [int] NULL,
[glc_cnt_stlmnt_sched] [int] NULL,
[glc_cnt_trans_payheader] [int] NULL,
[glc_cnt_closed_payheader] [int] NULL,
[glc_cnt_active_pyt] [int] NULL,
[glc_pct_active_pyt_nogl] [float] NULL,
[glc_pay_drv_no_act_table] [int] NULL,
[glc_pay_trc_no_act_table] [int] NULL,
[glc_pay_car_no_act_table] [int] NULL,
[glc_cnt_std_deduct] [int] NULL,
[glc_cnt_pyd_std_deduct] [int] NULL,
[glc_cnt_resources_std_deduct] [int] NULL,
[glc_pct_ap_trc_cld_payheader] [float] NULL,
[glc_pct_pr_drv_cld_payheader] [float] NULL,
[glc_pct_stl_autorated] [float] NULL,
[glc_pct_lh_pay] [float] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[golivecheck_settlements] TO [public]
GO
GRANT INSERT ON  [dbo].[golivecheck_settlements] TO [public]
GO
GRANT REFERENCES ON  [dbo].[golivecheck_settlements] TO [public]
GO
GRANT SELECT ON  [dbo].[golivecheck_settlements] TO [public]
GO
GRANT UPDATE ON  [dbo].[golivecheck_settlements] TO [public]
GO
