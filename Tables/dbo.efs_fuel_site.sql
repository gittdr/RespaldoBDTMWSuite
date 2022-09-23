CREATE TABLE [dbo].[efs_fuel_site]
(
[efs_truckstop] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[efs_chain_id] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_address] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_city] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_state] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_zip] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_phone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_time_zone] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_importbatch] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_updated_on] [datetime] NULL,
[efs_updated_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_created_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[efs_fuel_site] ADD CONSTRAINT [PK_efs_fuel_site] PRIMARY KEY NONCLUSTERED ([efs_truckstop]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[efs_fuel_site] TO [public]
GO
GRANT INSERT ON  [dbo].[efs_fuel_site] TO [public]
GO
GRANT SELECT ON  [dbo].[efs_fuel_site] TO [public]
GO
GRANT UPDATE ON  [dbo].[efs_fuel_site] TO [public]
GO
