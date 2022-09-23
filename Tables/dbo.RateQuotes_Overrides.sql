CREATE TABLE [dbo].[RateQuotes_Overrides]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[RateQuoteID] [int] NOT NULL,
[RevType1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevType2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevType3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevType4] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RateQuotes_Overrides] TO [public]
GO
GRANT INSERT ON  [dbo].[RateQuotes_Overrides] TO [public]
GO
GRANT SELECT ON  [dbo].[RateQuotes_Overrides] TO [public]
GO
GRANT UPDATE ON  [dbo].[RateQuotes_Overrides] TO [public]
GO
