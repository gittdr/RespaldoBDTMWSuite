CREATE TABLE [dbo].[region_service_level]
(
[region_id] [int] NOT NULL,
[region_servicelevel] [smallint] NOT NULL,
[region_lowweight] [float] NOT NULL,
[region_highweight] [float] NOT NULL,
[region_weightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[region_service_level] ADD CONSTRAINT [PK_region_service_level] PRIMARY KEY CLUSTERED ([region_id], [region_lowweight], [region_highweight]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[region_service_level] TO [public]
GO
GRANT INSERT ON  [dbo].[region_service_level] TO [public]
GO
GRANT REFERENCES ON  [dbo].[region_service_level] TO [public]
GO
GRANT SELECT ON  [dbo].[region_service_level] TO [public]
GO
GRANT UPDATE ON  [dbo].[region_service_level] TO [public]
GO
