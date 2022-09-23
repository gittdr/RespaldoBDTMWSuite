CREATE TABLE [dbo].[company_service_level]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_servicelevel] [smallint] NOT NULL,
[cmp_lowweight] [float] NOT NULL,
[cmp_highweight] [float] NOT NULL,
[cmp_weightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_service_level] ADD CONSTRAINT [PK_company_service_level] PRIMARY KEY CLUSTERED ([cmp_id], [cmp_lowweight], [cmp_highweight]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_service_level] TO [public]
GO
GRANT INSERT ON  [dbo].[company_service_level] TO [public]
GO
GRANT REFERENCES ON  [dbo].[company_service_level] TO [public]
GO
GRANT SELECT ON  [dbo].[company_service_level] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_service_level] TO [public]
GO
