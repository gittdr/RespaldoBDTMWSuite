CREATE TABLE [dbo].[paper_invoice]
(
[id_num] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NOT NULL,
[pi_car_invnum] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pi_car_invdate] [datetime] NULL,
[pi_desc] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pi_charge] [money] NULL,
[pi_comment] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pi_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pi_pyh_pyhnumber] [int] NULL,
[pi_pw_date] [datetime] NULL,
[lgh_number] [int] NULL,
[pi_date_created] [datetime] NULL,
[pi_createdby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pi_date_updated] [datetime] NULL,
[pi_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pi_workflowstatus] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[paper_invoice] ADD CONSTRAINT [pk_paper_invoice_id_num] PRIMARY KEY CLUSTERED ([id_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_paper_invoice_lgh] ON [dbo].[paper_invoice] ([lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_paper_invoice_ord_hdrnumber] ON [dbo].[paper_invoice] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[paper_invoice] TO [public]
GO
GRANT INSERT ON  [dbo].[paper_invoice] TO [public]
GO
GRANT REFERENCES ON  [dbo].[paper_invoice] TO [public]
GO
GRANT SELECT ON  [dbo].[paper_invoice] TO [public]
GO
GRANT UPDATE ON  [dbo].[paper_invoice] TO [public]
GO
