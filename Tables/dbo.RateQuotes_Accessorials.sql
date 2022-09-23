CREATE TABLE [dbo].[RateQuotes_Accessorials]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[RateQuoteID] [int] NOT NULL,
[AccCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Quantity] [decimal] (18, 0) NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RateQuotes_Accessorials] TO [public]
GO
GRANT INSERT ON  [dbo].[RateQuotes_Accessorials] TO [public]
GO
GRANT SELECT ON  [dbo].[RateQuotes_Accessorials] TO [public]
GO
GRANT UPDATE ON  [dbo].[RateQuotes_Accessorials] TO [public]
GO
