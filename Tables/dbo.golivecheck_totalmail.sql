CREATE TABLE [dbo].[golivecheck_totalmail]
(
[glc_rundate] [datetime] NULL,
[glc_cnt_tm_active_trc] [int] NULL,
[glc_cnt_tm_active_trc_no_mct] [int] NULL,
[glc_cnt_tm_non_error_msg] [int] NULL,
[glc_cnt_tm_error_msg] [int] NULL,
[glc_cnt_tm_users] [int] NULL,
[glc_cnt_tm_active_trc_no_grp] [int] NULL,
[glc_cnt_tm_ret_macro] [int] NULL,
[glc_cnt_tm_active_macro] [int] NULL,
[glc_pct_tm_cir_service_macros] [float] NULL,
[glc_cnt_tm_admin_inbox] [int] NULL,
[glc_pct_tm_admin_unread] [float] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[golivecheck_totalmail] TO [public]
GO
GRANT INSERT ON  [dbo].[golivecheck_totalmail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[golivecheck_totalmail] TO [public]
GO
GRANT SELECT ON  [dbo].[golivecheck_totalmail] TO [public]
GO
GRANT UPDATE ON  [dbo].[golivecheck_totalmail] TO [public]
GO
