CREATE TABLE [dbo].[Metric_TempCashReceipts]
(
[Customer ID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Post Date] [datetime] NULL,
[Invoice Number] [char] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreditDebitType] [int] NULL,
[Cash Amount] [money] NULL
) ON [PRIMARY]
GO
