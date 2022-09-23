CREATE TABLE [dbo].[LTLQuote_RequestHeader]
(
[QuoteID] [bigint] NOT NULL IDENTITY(1, 1),
[RequestDate] [datetime] NOT NULL,
[ResponseDate] [datetime] NULL,
[ErrorMessage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LTLQuote_RequestHeader_ErrorMessage] DEFAULT (''),
[QuoteStatus] [int] NULL CONSTRAINT [DF__LTLQuote___Quote__365D4B73] DEFAULT ((0)),
[RootUserName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__LTLQuote___RootU__4E34D504] DEFAULT (NULL),
[UserName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__LTLQuote___UserN__4F28F93D] DEFAULT (NULL),
[contractratesonly] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LTLQuote_RequestHeader] ADD CONSTRAINT [PK_LTLQuote_RequestHeader] PRIMARY KEY CLUSTERED ([QuoteID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[LTLQuote_RequestHeader] TO [public]
GO
GRANT INSERT ON  [dbo].[LTLQuote_RequestHeader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[LTLQuote_RequestHeader] TO [public]
GO
GRANT SELECT ON  [dbo].[LTLQuote_RequestHeader] TO [public]
GO
GRANT UPDATE ON  [dbo].[LTLQuote_RequestHeader] TO [public]
GO
