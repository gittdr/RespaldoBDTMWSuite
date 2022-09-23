CREATE TABLE [dbo].[PartPrice]
(
[pp_identity] [int] NOT NULL IDENTITY(1, 1),
[pp_businessunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pp_part_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pp_netprice] [money] NULL,
[pp_per_unit] [money] NULL,
[pp_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pp_country] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pp_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pp_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pp_date] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PartPrice] TO [public]
GO
GRANT INSERT ON  [dbo].[PartPrice] TO [public]
GO
GRANT SELECT ON  [dbo].[PartPrice] TO [public]
GO
GRANT UPDATE ON  [dbo].[PartPrice] TO [public]
GO
