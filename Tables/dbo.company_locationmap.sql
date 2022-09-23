CREATE TABLE [dbo].[company_locationmap]
(
[cmp_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[location_map] [image] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_locationmap] ADD CONSTRAINT [PK_company_locationmap] PRIMARY KEY CLUSTERED ([cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_locationmap] TO [public]
GO
GRANT INSERT ON  [dbo].[company_locationmap] TO [public]
GO
GRANT SELECT ON  [dbo].[company_locationmap] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_locationmap] TO [public]
GO
