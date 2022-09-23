CREATE TABLE [dbo].[eStatUserBillToMapCompanies]
(
[login] [varchar] (132) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[eStatUserBillToMapCompanies] ADD CONSTRAINT [PK_estatuserbilltocomp] PRIMARY KEY NONCLUSTERED ([login], [cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[eStatUserBillToMapCompanies] TO [public]
GO
GRANT INSERT ON  [dbo].[eStatUserBillToMapCompanies] TO [public]
GO
GRANT SELECT ON  [dbo].[eStatUserBillToMapCompanies] TO [public]
GO
GRANT UPDATE ON  [dbo].[eStatUserBillToMapCompanies] TO [public]
GO
