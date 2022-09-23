CREATE TABLE [dbo].[paydetail_disassociate]
(
[pddis_id] [int] NOT NULL IDENTITY(1, 1),
[pddis_userid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pddis_datetime] [datetime] NULL,
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_number] [int] NULL,
[pyh_number] [int] NULL,
[pyh_payperiod] [datetime] NULL,
[stp_number] [int] NULL,
[lgh_number] [int] NULL,
[ord_hdrnumber] [int] NULL,
[mov_number] [int] NULL,
[asgn_number] [int] NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_description] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_updsrc] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psd_id] [int] NULL,
[pyd_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_exportstatus] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[paydetail_disassociate] ADD CONSTRAINT [pk_pddis_id] PRIMARY KEY CLUSTERED ([pddis_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[paydetail_disassociate] TO [public]
GO
GRANT INSERT ON  [dbo].[paydetail_disassociate] TO [public]
GO
GRANT REFERENCES ON  [dbo].[paydetail_disassociate] TO [public]
GO
GRANT SELECT ON  [dbo].[paydetail_disassociate] TO [public]
GO
GRANT UPDATE ON  [dbo].[paydetail_disassociate] TO [public]
GO
