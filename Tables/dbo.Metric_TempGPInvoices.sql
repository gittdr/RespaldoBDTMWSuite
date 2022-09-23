CREATE TABLE [dbo].[Metric_TempGPInvoices]
(
[Customer ID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Doc Date] [datetime] NULL,
[Invoice Number] [char] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreditDebitType] [int] NULL,
[Invoice Amount] [money] NULL,
[Open Invoice Amount] [money] NULL,
[Prior Invoice Number] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastPaymentAppliedDate] [datetime] NULL,
[Days To Pay] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxInvoiceAmount] ON [dbo].[Metric_TempGPInvoices] ([Invoice Amount]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxInvoiceNumber] ON [dbo].[Metric_TempGPInvoices] ([Invoice Number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxPriorInvoiceNumber] ON [dbo].[Metric_TempGPInvoices] ([Prior Invoice Number]) ON [PRIMARY]
GO
