CREATE TABLE [dbo].[plant_supplier_holiday]
(
[psh_id] [int] NOT NULL IDENTITY(1, 1),
[psh_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[psh_date] [datetime] NOT NULL,
[psh_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[plant_supplier_holiday] TO [public]
GO
GRANT INSERT ON  [dbo].[plant_supplier_holiday] TO [public]
GO
GRANT SELECT ON  [dbo].[plant_supplier_holiday] TO [public]
GO
GRANT UPDATE ON  [dbo].[plant_supplier_holiday] TO [public]
GO
