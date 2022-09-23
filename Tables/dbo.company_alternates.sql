CREATE TABLE [dbo].[company_alternates]
(
[ca_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ca_alt] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [dk_ca_alt] ON [dbo].[company_alternates] ([ca_alt]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ca_id] ON [dbo].[company_alternates] ([ca_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_alternates] TO [public]
GO
GRANT INSERT ON  [dbo].[company_alternates] TO [public]
GO
GRANT REFERENCES ON  [dbo].[company_alternates] TO [public]
GO
GRANT SELECT ON  [dbo].[company_alternates] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_alternates] TO [public]
GO
