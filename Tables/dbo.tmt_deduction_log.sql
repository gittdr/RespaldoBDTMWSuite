CREATE TABLE [dbo].[tmt_deduction_log]
(
[tdl_id] [int] NOT NULL IDENTITY(1, 1),
[tdl_user] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tdl_entrytime] [datetime] NULL CONSTRAINT [DF__tmt_deduc__tdl_e__073ED4B8] DEFAULT (getdate()),
[tdl_error] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__tmt_deduc__tdl_e__0832F8F1] DEFAULT ('N'),
[tdl_message] [varchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tdl_std_message] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_number] [int] NULL,
[pyd_number_escrow] [int] NULL,
[pyd_number_advance] [int] NULL,
[tdl_escrow_deduct] [money] NULL,
[tdl_advance_amount] [money] NULL,
[tmt_order_id] [int] NULL,
[tmt_inv_order_num] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmt_change_date] [datetime] NULL,
[tmt_drv_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmt_trc_number] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmt_amount] [money] NULL,
[tmt_shopid] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmt_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmt_rep_reason] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[tmt_deduction_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tmt_deduction_log] TO [public]
GO
GRANT SELECT ON  [dbo].[tmt_deduction_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[tmt_deduction_log] TO [public]
GO
