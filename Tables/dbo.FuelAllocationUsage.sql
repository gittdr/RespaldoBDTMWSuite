CREATE TABLE [dbo].[FuelAllocationUsage]
(
[LoadDate] [datetime] NOT NULL,
[Complete] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillTo] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Supplier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AccountOf] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CommodityClass] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Commodity] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Volume] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ux_FuelAllocationUsage_uniquefields] ON [dbo].[FuelAllocationUsage] ([LoadDate], [Complete], [BillTo], [Shipper], [Supplier], [AccountOf], [CommodityClass], [Commodity]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FuelAllocationUsage] TO [public]
GO
GRANT INSERT ON  [dbo].[FuelAllocationUsage] TO [public]
GO
GRANT SELECT ON  [dbo].[FuelAllocationUsage] TO [public]
GO
GRANT UPDATE ON  [dbo].[FuelAllocationUsage] TO [public]
GO
