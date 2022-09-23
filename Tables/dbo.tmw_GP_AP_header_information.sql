CREATE TABLE [dbo].[tmw_GP_AP_header_information]
(
[tmw_gp_ap_vendorid] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmw_gp_ap_vouchernumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmw_gp_ap_bachnumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmw_gp_ap_bachdate] [datetime] NULL,
[tmw_gp_ap_payheadernumber] [int] NULL,
[tmw_gp_ap_payto] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmw_gp_ap_docnumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmw_gp_ap_docdescription] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmw_gp_ap_docdate] [datetime] NULL,
[tmw_gp_ap_postdate] [datetime] NULL,
[tmw_gp_ap_documenttotal] [decimal] (8, 2) NULL,
[tmw_gp_ap_GPcompDB] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[gp_ap_doctype] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmw_gp_ap_vouchernumberCM] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmw_gp_ap_PayheaderIsFullyApplied] [int] NULL,
[tmw_gp_ap_GLPostDate] [datetime] NULL,
[gp_ap_last_checkdate] [datetime] NULL,
[gp_ap_last_checkamount] [decimal] (9, 2) NULL,
[gp_ap_last_checknumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gp_ap_amount_remaining] [decimal] (9, 2) NULL,
[gp_ap_server] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tmw_GP_AP_header_information] TO [public]
GO
GRANT INSERT ON  [dbo].[tmw_GP_AP_header_information] TO [public]
GO
GRANT SELECT ON  [dbo].[tmw_GP_AP_header_information] TO [public]
GO
GRANT UPDATE ON  [dbo].[tmw_GP_AP_header_information] TO [public]
GO
