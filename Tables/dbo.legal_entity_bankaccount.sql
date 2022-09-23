CREATE TABLE [dbo].[legal_entity_bankaccount]
(
[leba_le_id] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[leba_country] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[leba_bank_account] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[legal_entity_bankaccount] TO [public]
GO
GRANT INSERT ON  [dbo].[legal_entity_bankaccount] TO [public]
GO
GRANT REFERENCES ON  [dbo].[legal_entity_bankaccount] TO [public]
GO
GRANT SELECT ON  [dbo].[legal_entity_bankaccount] TO [public]
GO
GRANT UPDATE ON  [dbo].[legal_entity_bankaccount] TO [public]
GO
