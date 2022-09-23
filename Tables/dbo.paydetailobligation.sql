CREATE TABLE [dbo].[paydetailobligation]
(
[pdo_ident] [int] NOT NULL IDENTITY(1, 1),
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_amount] [money] NULL,
[pyh_number] [int] NULL,
[pyh_payperiod] [datetime] NULL,
[pyd_number] [int] NOT NULL,
[std_number] [int] NULL,
[pdo_processingdt] [datetime] NULL,
[pyd_updatedon] [datetime] NULL,
[pdo_createdon] [datetime] NULL,
[pdo_createdby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[paydetailobligation] ADD CONSTRAINT [pk_pdo_ident] PRIMARY KEY CLUSTERED ([pdo_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[paydetailobligation] TO [public]
GO
GRANT INSERT ON  [dbo].[paydetailobligation] TO [public]
GO
GRANT REFERENCES ON  [dbo].[paydetailobligation] TO [public]
GO
GRANT SELECT ON  [dbo].[paydetailobligation] TO [public]
GO
GRANT UPDATE ON  [dbo].[paydetailobligation] TO [public]
GO
