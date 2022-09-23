CREATE TABLE [dbo].[paydetailobligationhistory]
(
[pdh_ident] [int] NOT NULL IDENTITY(1, 1),
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_amount] [money] NULL,
[pyh_number] [int] NULL,
[pyh_payperiod] [datetime] NULL,
[pyd_number] [int] NOT NULL,
[std_number] [int] NULL,
[pdo_processingdt] [datetime] NULL,
[pdh_prior_balance] [money] NULL,
[pdh_new_balance] [money] NULL,
[pdh_payperiod_deducted] [datetime] NULL,
[pdh_batchdt] [datetime] NULL,
[check_number] [int] NULL,
[pdo_activity] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_updatedon] [datetime] NULL,
[pdh_createdon] [datetime] NULL,
[pdh_createdby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[paydetailobligationhistory] ADD CONSTRAINT [pk_pdh_ident] PRIMARY KEY CLUSTERED ([pdh_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[paydetailobligationhistory] TO [public]
GO
GRANT INSERT ON  [dbo].[paydetailobligationhistory] TO [public]
GO
GRANT REFERENCES ON  [dbo].[paydetailobligationhistory] TO [public]
GO
GRANT SELECT ON  [dbo].[paydetailobligationhistory] TO [public]
GO
GRANT UPDATE ON  [dbo].[paydetailobligationhistory] TO [public]
GO
