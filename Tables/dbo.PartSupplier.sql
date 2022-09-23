CREATE TABLE [dbo].[PartSupplier]
(
[ps_identity] [int] NOT NULL IDENTITY(1, 1),
[ps_vendor] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ps_part_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ps_supplier_alias] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ps_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PartSupplier] TO [public]
GO
GRANT INSERT ON  [dbo].[PartSupplier] TO [public]
GO
GRANT SELECT ON  [dbo].[PartSupplier] TO [public]
GO
GRANT UPDATE ON  [dbo].[PartSupplier] TO [public]
GO
