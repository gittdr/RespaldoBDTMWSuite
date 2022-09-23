CREATE TABLE [dbo].[tmw_GP_AP_transfer_types]
(
[tmw_gp_ap_tt_ap_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmw_gp_ap_tt_docnumber] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmw_gp_ap_tt_docdescription] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmw_gp_ap_tt_docdate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmw_gp_ap_tt_postingdate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmw_gp_ap_tt_ponumber] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tmw_GP_AP_transfer_types] TO [public]
GO
GRANT INSERT ON  [dbo].[tmw_GP_AP_transfer_types] TO [public]
GO
GRANT SELECT ON  [dbo].[tmw_GP_AP_transfer_types] TO [public]
GO
GRANT UPDATE ON  [dbo].[tmw_GP_AP_transfer_types] TO [public]
GO
