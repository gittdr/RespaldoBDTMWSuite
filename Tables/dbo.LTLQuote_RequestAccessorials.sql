CREATE TABLE [dbo].[LTLQuote_RequestAccessorials]
(
[QuoteID] [int] NOT NULL CONSTRAINT [DF_LTLQuote_RequestAccessorials_QuoteID] DEFAULT ((0)),
[Accessorial] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[LTLQuote_RequestAccessorials] TO [public]
GO
GRANT INSERT ON  [dbo].[LTLQuote_RequestAccessorials] TO [public]
GO
GRANT REFERENCES ON  [dbo].[LTLQuote_RequestAccessorials] TO [public]
GO
GRANT SELECT ON  [dbo].[LTLQuote_RequestAccessorials] TO [public]
GO
GRANT UPDATE ON  [dbo].[LTLQuote_RequestAccessorials] TO [public]
GO
