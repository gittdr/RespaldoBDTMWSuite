CREATE TABLE [dbo].[invoicedetail_gl]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[ivd_number] [int] NULL,
[glnum] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[base_glnum] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[account_type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amount] [money] NULL,
[debit_amount] [money] NULL,
[credit_amount] [money] NULL,
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[invoicedetail_gl] ADD CONSTRAINT [PK__invoiced__3213E83FFB67521B] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[invoicedetail_gl] TO [public]
GO
GRANT INSERT ON  [dbo].[invoicedetail_gl] TO [public]
GO
GRANT REFERENCES ON  [dbo].[invoicedetail_gl] TO [public]
GO
GRANT SELECT ON  [dbo].[invoicedetail_gl] TO [public]
GO
GRANT UPDATE ON  [dbo].[invoicedetail_gl] TO [public]
GO
