CREATE TABLE [dbo].[ACCT_OutstandingReceivables]
(
[InvoiceNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BatchDate] [datetime] NULL,
[AmountReceived] [money] NULL,
[NetCode] [int] NULL,
[OpenACCTInvoiceAmount] [money] NULL,
[LastPaymentAppliedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACCT_OutstandingReceivables] ADD CONSTRAINT [PK_ACCT_OutstandingReceivables] PRIMARY KEY CLUSTERED ([InvoiceNumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ACCT_OutstandingReceivables] TO [public]
GO
GRANT INSERT ON  [dbo].[ACCT_OutstandingReceivables] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ACCT_OutstandingReceivables] TO [public]
GO
GRANT SELECT ON  [dbo].[ACCT_OutstandingReceivables] TO [public]
GO
GRANT UPDATE ON  [dbo].[ACCT_OutstandingReceivables] TO [public]
GO
