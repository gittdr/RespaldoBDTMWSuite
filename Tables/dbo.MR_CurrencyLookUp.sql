CREATE TABLE [dbo].[MR_CurrencyLookUp]
(
[cl_currencyflag] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cl_currency] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cl_picturelocation] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MR_CurrencyLookUp] ADD CONSTRAINT [PK_MR_CurrencyLookUp] PRIMARY KEY CLUSTERED ([cl_currencyflag], [cl_currency]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MR_CurrencyLookUp] TO [public]
GO
GRANT INSERT ON  [dbo].[MR_CurrencyLookUp] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MR_CurrencyLookUp] TO [public]
GO
GRANT SELECT ON  [dbo].[MR_CurrencyLookUp] TO [public]
GO
GRANT UPDATE ON  [dbo].[MR_CurrencyLookUp] TO [public]
GO
