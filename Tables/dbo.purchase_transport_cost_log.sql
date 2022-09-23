CREATE TABLE [dbo].[purchase_transport_cost_log]
(
[ptcl_id] [int] NOT NULL IDENTITY(1, 1),
[lgh_number] [int] NULL,
[ptcl_start_date] [datetime] NULL,
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ptcl_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ptcl_updatedate] [datetime] NULL,
[ptcl_billing_linehaul] [money] NULL,
[ptcl_billing_total] [money] NULL,
[ptcl_pay_linehaul] [money] NULL,
[ptcl_pay_fsc] [money] NULL,
[ptcl_pay_total] [money] NULL,
[ptc_id] [int] NULL,
[ptc_linehaul] [money] NULL,
[ptc_locked] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ptc_amtover] [money] NULL,
[ptc_amtover_basis] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ptc_minmargin] [decimal] (5, 2) NULL,
[ptc_minmargin_basis] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ptc_minmargin_locked] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ptc_date] [datetime] NULL,
[ptc_mode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ptc_override_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ptc_override_reason] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[purchase_transport_cost_log] ADD CONSTRAINT [pk_purchase_transport_cost_log_ptcl_id] PRIMARY KEY CLUSTERED ([ptcl_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[purchase_transport_cost_log] TO [public]
GO
GRANT INSERT ON  [dbo].[purchase_transport_cost_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[purchase_transport_cost_log] TO [public]
GO
GRANT SELECT ON  [dbo].[purchase_transport_cost_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[purchase_transport_cost_log] TO [public]
GO
