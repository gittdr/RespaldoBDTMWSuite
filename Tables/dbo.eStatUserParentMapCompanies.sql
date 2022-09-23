CREATE TABLE [dbo].[eStatUserParentMapCompanies]
(
[login] [varchar] (132) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[eStatUserParentMapCompanies] ADD CONSTRAINT [PK_estatuserparentcomp] PRIMARY KEY NONCLUSTERED ([login], [cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[eStatUserParentMapCompanies] TO [public]
GO
GRANT INSERT ON  [dbo].[eStatUserParentMapCompanies] TO [public]
GO
GRANT SELECT ON  [dbo].[eStatUserParentMapCompanies] TO [public]
GO
GRANT UPDATE ON  [dbo].[eStatUserParentMapCompanies] TO [public]
GO
