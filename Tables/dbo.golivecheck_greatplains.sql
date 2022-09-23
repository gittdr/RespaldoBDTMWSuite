CREATE TABLE [dbo].[golivecheck_greatplains]
(
[glc_rundate] [datetime] NULL,
[glc_cnt_gp_cust_invalid_class] [int] NULL,
[glc_cnt_gp_vend_invalid_class] [int] NULL,
[glc_cnt_gp_gl_acct_structure] [int] NULL,
[glc_cnt_gp_bal_acct_sheets] [int] NULL,
[glc_cnt_gp_income_stmnt_accts] [int] NULL,
[glc_cnt_gp_acct_yr_setup] [int] NULL,
[glc_cnt_gp_cust_no_ar_acct] [int] NULL,
[glc_cnt_gp_vend_no_ap_acct] [int] NULL,
[glc_cnt_gp_ten99_vend] [int] NULL,
[glc_gp_ztrans_setup] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[glc_cnt_gp_cust_classes] [int] NULL,
[glc_gp_cust_class_defined] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[glc_gp_vend_class_defined] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[glc_cnt_act_employee_payroll] [int] NULL,
[glc_cnt_paycode_asgn_employee] [int] NULL,
[glc_cnt_dedcode_asgn_employee] [int] NULL,
[glc_cnt_fedtax_emp_recs] [int] NULL,
[glc_cnt_act_statetax_emp_recs] [int] NULL,
[glc_cnt_act_localtax_emp_recs] [int] NULL,
[glc_cnt_act_dirdep_emp_recs] [int] NULL,
[glc_cnt_act_dirdep_emp_accts] [int] NULL,
[glc_cnt_act_dirdep_recs_prenote] [int] NULL,
[glc_gp_payroll_dirdep_setup] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[glc_cnt_eft_vend_recs] [int] NULL,
[glc_gp_eft_vend_setup] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[glc_cnt_post_gl_entries] [int] NULL,
[glc_cnt_unpost_gl_entries] [int] NULL,
[glc_cnt_post_ap_invoices] [int] NULL,
[glc_cnt_unpost_ap_invoices] [int] NULL,
[glc_cnt_post_ap_check_credit] [int] NULL,
[glc_cnt_payroll_checks_dirdep] [int] NULL,
[glc_cnt_post_ar_invoices] [int] NULL,
[glc_cnt_unpost_ar_invoices] [int] NULL,
[glc_cnt_check_credit_applied] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[golivecheck_greatplains] TO [public]
GO
GRANT INSERT ON  [dbo].[golivecheck_greatplains] TO [public]
GO
GRANT REFERENCES ON  [dbo].[golivecheck_greatplains] TO [public]
GO
GRANT SELECT ON  [dbo].[golivecheck_greatplains] TO [public]
GO
GRANT UPDATE ON  [dbo].[golivecheck_greatplains] TO [public]
GO
