CREATE TABLE [dbo].[company_group_info]
(
[grp_id] [int] NOT NULL,
[grp_abbr] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[grp_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_group_info] ADD CONSTRAINT [pk_company_group_info] PRIMARY KEY NONCLUSTERED ([grp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_group_info] TO [public]
GO
GRANT INSERT ON  [dbo].[company_group_info] TO [public]
GO
GRANT REFERENCES ON  [dbo].[company_group_info] TO [public]
GO
GRANT SELECT ON  [dbo].[company_group_info] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_group_info] TO [public]
GO
