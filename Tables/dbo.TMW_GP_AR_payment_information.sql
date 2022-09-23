CREATE TABLE [dbo].[TMW_GP_AR_payment_information]
(
[tmw_gp_ar_pay_id] [int] NULL,
[tmw_gp_ar_invhdrnumber] [int] NULL,
[tmw_gp_ar_docnumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tmw_gp_ar_custnumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tmw_gp_ar_applyfromdocnumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tmw_gp_ar_appltoyglpostdate] [datetime] NOT NULL,
[tmw_gp_ar_appliedamount] [money] NULL,
[tmw_gp_ar_applydate] [datetime] NOT NULL,
[tmw_gp_ar_applyglfrompostdate] [datetime] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMW_GP_AR_payment_information] TO [public]
GO
GRANT INSERT ON  [dbo].[TMW_GP_AR_payment_information] TO [public]
GO
GRANT SELECT ON  [dbo].[TMW_GP_AR_payment_information] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMW_GP_AR_payment_information] TO [public]
GO
