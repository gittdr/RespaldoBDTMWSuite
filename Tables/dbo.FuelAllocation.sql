CREATE TABLE [dbo].[FuelAllocation]
(
[FAID] [int] NOT NULL IDENTITY(1, 1),
[AllocationDate] [datetime] NOT NULL,
[BillTo] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Supplier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AccountOf] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CommodityClass] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Commodity] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AllocationAmount] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FuelAllocation] ADD CONSTRAINT [PK__FuelAllocation__12BF097B] PRIMARY KEY CLUSTERED ([FAID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_FuelAllocation_uniquefields] ON [dbo].[FuelAllocation] ([AllocationDate], [BillTo], [Shipper], [Supplier], [AccountOf], [CommodityClass], [Commodity]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FuelAllocation] TO [public]
GO
GRANT INSERT ON  [dbo].[FuelAllocation] TO [public]
GO
GRANT SELECT ON  [dbo].[FuelAllocation] TO [public]
GO
GRANT UPDATE ON  [dbo].[FuelAllocation] TO [public]
GO
