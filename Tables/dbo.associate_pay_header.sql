CREATE TABLE [dbo].[associate_pay_header]
(
[branch_pay_header_id] [int] NOT NULL,
[entry_id] [int] NOT NULL,
[ord_hdrnumber] [int] NOT NULL,
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[topup_truck_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[branch_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[involvement_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[order_revenue] [money] NOT NULL,
[segment_alloc_pct] [float] NULL,
[segment_alloc_amt] [money] NULL,
[credit_debit] [money] NULL,
[ic_pay] [money] NULL,
[notes] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_number] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[associate_pay_header] ADD CONSTRAINT [associate_pay_header_pk] PRIMARY KEY CLUSTERED ([branch_pay_header_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[associate_pay_header] TO [public]
GO
GRANT INSERT ON  [dbo].[associate_pay_header] TO [public]
GO
GRANT SELECT ON  [dbo].[associate_pay_header] TO [public]
GO
GRANT UPDATE ON  [dbo].[associate_pay_header] TO [public]
GO
