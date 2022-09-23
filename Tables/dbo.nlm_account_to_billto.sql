CREATE TABLE [dbo].[nlm_account_to_billto]
(
[nlm_account_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_to_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order_by_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[nlm_account_to_billto] TO [public]
GO
GRANT INSERT ON  [dbo].[nlm_account_to_billto] TO [public]
GO
GRANT REFERENCES ON  [dbo].[nlm_account_to_billto] TO [public]
GO
GRANT SELECT ON  [dbo].[nlm_account_to_billto] TO [public]
GO
GRANT UPDATE ON  [dbo].[nlm_account_to_billto] TO [public]
GO
