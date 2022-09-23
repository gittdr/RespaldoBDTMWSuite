CREATE TABLE [dbo].[cdposttran_paydetail]
(
[cdposttran_pyd_number] [int] NOT NULL,
[paydetail_pyd_number] [int] NOT NULL,
[cp_amount] [money] NULL,
[cp_transaction_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdposttran_paydetail] ADD CONSTRAINT [PK_cdposttran_paydetail] PRIMARY KEY NONCLUSTERED ([cdposttran_pyd_number], [paydetail_pyd_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cdposttran_paydetail] TO [public]
GO
GRANT INSERT ON  [dbo].[cdposttran_paydetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdposttran_paydetail] TO [public]
GO
GRANT SELECT ON  [dbo].[cdposttran_paydetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdposttran_paydetail] TO [public]
GO
