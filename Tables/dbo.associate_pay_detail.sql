CREATE TABLE [dbo].[associate_pay_detail]
(
[branch_pay_header_id] [int] NOT NULL,
[item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[revenue_pct] [float] NULL,
[amount] [money] NULL,
[from_to_branch_id] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[notes] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_number] [int] NOT NULL,
[apd_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[associate_pay_detail] ADD CONSTRAINT [associate_pay_detail_pk] PRIMARY KEY CLUSTERED ([pyd_number]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [associate_pay_detail_cu2] ON [dbo].[associate_pay_detail] ([branch_pay_header_id], [item]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[associate_pay_detail] TO [public]
GO
GRANT INSERT ON  [dbo].[associate_pay_detail] TO [public]
GO
GRANT SELECT ON  [dbo].[associate_pay_detail] TO [public]
GO
GRANT UPDATE ON  [dbo].[associate_pay_detail] TO [public]
GO
