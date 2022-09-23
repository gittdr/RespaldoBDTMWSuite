CREATE TABLE [dbo].[tck_fuel_optimization]
(
[tfo_id] [int] NOT NULL,
[tfo_expiration_date] [datetime] NULL,
[tfo_maximum_truck_volume] [money] NULL,
[tfo_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tfo_sitenumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tck_account_number] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_cardnumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_cardnumbershort] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tfo_updated_on] [datetime] NULL,
[tfo_updated_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tfo_created_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tck_fuel_optimization] ADD CONSTRAINT [PK_tck_fuel_optimization] PRIMARY KEY NONCLUSTERED ([tfo_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tck_fuel_optimization] TO [public]
GO
GRANT INSERT ON  [dbo].[tck_fuel_optimization] TO [public]
GO
GRANT SELECT ON  [dbo].[tck_fuel_optimization] TO [public]
GO
GRANT UPDATE ON  [dbo].[tck_fuel_optimization] TO [public]
GO
