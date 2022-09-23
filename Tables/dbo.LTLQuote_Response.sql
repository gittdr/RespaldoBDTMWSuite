CREATE TABLE [dbo].[LTLQuote_Response]
(
[QuoteID] [bigint] NOT NULL CONSTRAINT [DF_LTLQuote_Response_QuoteID] DEFAULT ((0)),
[CarrierQuotes] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayDetails] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LTLQuote_Response_PayDetails] DEFAULT (NULL),
[InvoiceDetails] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LTLQuote_Response_InvoiceDetails] DEFAULT (NULL),
[OrderHeader] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LTLQuote_Response_OrderHeader] DEFAULT (NULL)
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[LTLQuote_Response] TO [public]
GO
GRANT INSERT ON  [dbo].[LTLQuote_Response] TO [public]
GO
GRANT REFERENCES ON  [dbo].[LTLQuote_Response] TO [public]
GO
GRANT SELECT ON  [dbo].[LTLQuote_Response] TO [public]
GO
GRANT UPDATE ON  [dbo].[LTLQuote_Response] TO [public]
GO
