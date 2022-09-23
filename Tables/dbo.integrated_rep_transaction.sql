CREATE TABLE [dbo].[integrated_rep_transaction]
(
[irt_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[irt_logid] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irt_logpass] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irt_autocommit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irt_database] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irt_server] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irt_dbms] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irt_dbparm] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[integrated_rep_transaction] ADD CONSTRAINT [PK_integratedreptransaction] PRIMARY KEY NONCLUSTERED ([irt_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[integrated_rep_transaction] TO [public]
GO
GRANT INSERT ON  [dbo].[integrated_rep_transaction] TO [public]
GO
GRANT REFERENCES ON  [dbo].[integrated_rep_transaction] TO [public]
GO
GRANT SELECT ON  [dbo].[integrated_rep_transaction] TO [public]
GO
GRANT UPDATE ON  [dbo].[integrated_rep_transaction] TO [public]
GO
