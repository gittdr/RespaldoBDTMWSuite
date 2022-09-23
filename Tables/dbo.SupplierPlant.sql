CREATE TABLE [dbo].[SupplierPlant]
(
[sp_alias] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sp_plant] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sp_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sp_new_plant] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SupplierPlant] TO [public]
GO
GRANT INSERT ON  [dbo].[SupplierPlant] TO [public]
GO
GRANT REFERENCES ON  [dbo].[SupplierPlant] TO [public]
GO
GRANT SELECT ON  [dbo].[SupplierPlant] TO [public]
GO
GRANT UPDATE ON  [dbo].[SupplierPlant] TO [public]
GO
