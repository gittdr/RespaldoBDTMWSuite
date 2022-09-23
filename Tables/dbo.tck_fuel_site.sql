CREATE TABLE [dbo].[tck_fuel_site]
(
[tfs_site_number] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tfs_site_type] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tfs_site_name] [varchar] (46) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tfs_network_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tfs_physical_address] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tfs_physical_city] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tfs_physical_state] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tfs_physical_postal_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tfs_physical_country_code] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tfs_phone] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tfs_fax] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tfs_site_manager] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tfs_longitude] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tfs_longitude_direction] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tfs_latitude] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tfs_latitude_direction] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tfs_importbatch] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tfs_updated_on] [datetime] NULL,
[tfs_updated_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tfs_created_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tck_fuel_site] ADD CONSTRAINT [PK_tck_fuel_site] PRIMARY KEY NONCLUSTERED ([tfs_site_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tck_fuel_site] TO [public]
GO
GRANT INSERT ON  [dbo].[tck_fuel_site] TO [public]
GO
GRANT SELECT ON  [dbo].[tck_fuel_site] TO [public]
GO
GRANT UPDATE ON  [dbo].[tck_fuel_site] TO [public]
GO
