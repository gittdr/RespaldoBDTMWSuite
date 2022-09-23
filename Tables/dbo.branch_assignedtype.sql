CREATE TABLE [dbo].[branch_assignedtype]
(
[bat_id] [int] NOT NULL IDENTITY(1, 1),
[brn_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bat_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bat_value] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bat_default] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bat_active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bat_display_order] [int] NULL,
[bat_last_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bat_last_updatedon] [datetime] NULL,
[bat_pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_bat_pyt_itemcode] DEFAULT ('UNK'),
[bat_payroll_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_bat_payroll_flag] DEFAULT ('N'),
[bat_cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_bat_cht_itemcode] DEFAULT ('UNK'),
[bat_billing_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_bat_billing_flag] DEFAULT ('N'),
[bat_eventcodes] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_bat_eventcodes] DEFAULT (''),
[bat_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_bat_billto] DEFAULT ('UNKNOWN'),
[bat_pass_through] [tinyint] NULL,
[bat_pass_through_qty] [int] NULL,
[bat_pass_through_chargetypes] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bat_qty_protected] [tinyint] NULL,
[bat_rate_protected] [tinyint] NULL,
[bat_no_edit] [tinyint] NULL,
[bat_invoice_with_linehaul] [tinyint] NULL,
[bat_invoice_separate] [tinyint] NULL,
[bat_pickup_seq] [int] NULL,
[bat_drop_seq] [int] NULL,
[bat_stp_type_seq] [int] NULL,
[bat_stp_type] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bat_inv_wlinehaul] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bat_inv_group] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bat_inv_print] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bat_inv_edi] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bat_inv_web] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bat_is_label_file] [tinyint] NULL,
[ir_id] [int] NULL,
[bat_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bat_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bat_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bat_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bat_invoice_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bat_ratemode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_bat_ratemode] DEFAULT ('UNK'),
[bat_ExcludeFromInvoice] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[branch_assignedtype] ADD CONSTRAINT [PK__branch_assignedt__39FD646D] PRIMARY KEY NONCLUSTERED ([bat_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [BrAssignedType_id_billto_typeIndex] ON [dbo].[branch_assignedtype] ([brn_id], [bat_billto], [bat_type]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [idx_branch_assignedtype_1] ON [dbo].[branch_assignedtype] ([brn_id], [bat_type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[branch_assignedtype] TO [public]
GO
GRANT INSERT ON  [dbo].[branch_assignedtype] TO [public]
GO
GRANT SELECT ON  [dbo].[branch_assignedtype] TO [public]
GO
GRANT UPDATE ON  [dbo].[branch_assignedtype] TO [public]
GO
