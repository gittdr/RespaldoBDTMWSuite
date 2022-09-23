CREATE TABLE [dbo].[tmw_GP_AP_payment_information]
(
[tmw_gp_ap_pay_id] [int] NOT NULL IDENTITY(1, 1),
[tmw_gp_ap_pay_docnumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmw_gp_ap_pay_vendorid] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmw_gp_ap_pay_docdate] [datetime] NULL,
[tmw_gp_ap_pay_vouchernumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmw_gp_ap_pay_applyto_docnumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmw_gp_ap_pay_applyto_vouchernumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmw_gp_ap_pay_applyto_docdate] [datetime] NULL,
[tmw_gp_ap_pay_Actual_Apply_To_Amount] [decimal] (8, 2) NULL,
[tmw_gp_ap_pay_Applied_from_applied_amount] [decimal] (8, 2) NULL,
[tmw_gp_ap_pay_apply_from_docnumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmw_gp_ap_pay_payheadernumber] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tmw_GP_AP_payment_information] TO [public]
GO
GRANT INSERT ON  [dbo].[tmw_GP_AP_payment_information] TO [public]
GO
GRANT SELECT ON  [dbo].[tmw_GP_AP_payment_information] TO [public]
GO
GRANT UPDATE ON  [dbo].[tmw_GP_AP_payment_information] TO [public]
GO
