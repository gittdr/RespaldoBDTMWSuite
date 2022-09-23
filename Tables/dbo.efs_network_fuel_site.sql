CREATE TABLE [dbo].[efs_network_fuel_site]
(
[efs_truckstop] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[efs_Account] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_Branch] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_address] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_city] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_state] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_zip5] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_zip4] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_truckstop_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_interstate] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_exit3] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_exit4] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_area_code] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_phone_exchange] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_phone_number] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_account_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_chain_id] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_chain_suffix] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_start_time] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_end_time] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_maximum_fuel] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_rack_average] [decimal] (18, 6) NOT NULL,
[efs_federal_tax] [decimal] (18, 6) NULL,
[efs_state_tax] [decimal] (18, 6) NULL,
[efs_freight] [decimal] (18, 6) NULL,
[efs_miscellaneous] [decimal] (18, 6) NULL,
[efs_sales_tax] [decimal] (18, 6) NULL,
[efs_plus] [decimal] (18, 6) NULL,
[efs_total_cost] [decimal] (18, 6) NULL,
[efs_pump_price] [decimal] (18, 6) NULL,
[efs_savings_sign] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_savings] [decimal] (18, 6) NULL,
[efs_service_minor_repairs] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_service_tire_repair] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_service_truck_wash] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_service_scales] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_service_filler] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_service_showers] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_service_restaurant] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_service_deli] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_importbatch] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_updated_on] [datetime] NULL,
[efs_updated_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_created_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[efs_network_fuel_site] ADD CONSTRAINT [PK_efs_opti_fuel_site] PRIMARY KEY NONCLUSTERED ([efs_truckstop]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[efs_network_fuel_site] TO [public]
GO
GRANT INSERT ON  [dbo].[efs_network_fuel_site] TO [public]
GO
GRANT SELECT ON  [dbo].[efs_network_fuel_site] TO [public]
GO
GRANT UPDATE ON  [dbo].[efs_network_fuel_site] TO [public]
GO
