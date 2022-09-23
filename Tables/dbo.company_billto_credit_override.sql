CREATE TABLE [dbo].[company_billto_credit_override]
(
[ovr_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ovr_date] [datetime] NOT NULL,
[ovr_orders] [int] NULL,
[ovr_amount] [money] NULL,
[ovr_updatedby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ovr_updateddate] [datetime] NOT NULL,
[ovr_approvedby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ovr_remarks] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ovr_bookedorders] [int] NOT NULL,
[ovr_id] [int] NOT NULL IDENTITY(1, 1),
[ovr_enddate] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_billto_credit_override] TO [public]
GO
GRANT INSERT ON  [dbo].[company_billto_credit_override] TO [public]
GO
GRANT REFERENCES ON  [dbo].[company_billto_credit_override] TO [public]
GO
GRANT SELECT ON  [dbo].[company_billto_credit_override] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_billto_credit_override] TO [public]
GO
