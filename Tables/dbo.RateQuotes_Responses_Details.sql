CREATE TABLE [dbo].[RateQuotes_Responses_Details]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[RateQuoteResponseID] [int] NOT NULL,
[AccCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RateQuotes_Responses_Details_AccCode] DEFAULT (''),
[TotalCost] [decimal] (18, 0) NOT NULL,
[TotalRevenue] [decimal] (18, 0) NOT NULL,
[Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RateTypeDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rate] [decimal] (18, 2) NULL,
[RateQty] [decimal] (18, 2) NULL,
[RevRate] [decimal] (18, 2) NULL,
[RevRateQty] [decimal] (18, 2) NULL,
[RevDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevRateTypeDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevAccCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RateQuotes_Responses_Details] TO [public]
GO
GRANT INSERT ON  [dbo].[RateQuotes_Responses_Details] TO [public]
GO
GRANT SELECT ON  [dbo].[RateQuotes_Responses_Details] TO [public]
GO
GRANT UPDATE ON  [dbo].[RateQuotes_Responses_Details] TO [public]
GO
