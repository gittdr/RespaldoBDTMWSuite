CREATE TABLE [dbo].[RateQuotes_Orders]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[RateQuoteResponseID] [int] NOT NULL,
[OrderHeaderNumber] [int] NOT NULL,
[CreatedDateTime] [datetime] NULL,
[CreateByUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RateQuotes_Orders] TO [public]
GO
GRANT INSERT ON  [dbo].[RateQuotes_Orders] TO [public]
GO
GRANT SELECT ON  [dbo].[RateQuotes_Orders] TO [public]
GO
GRANT UPDATE ON  [dbo].[RateQuotes_Orders] TO [public]
GO
