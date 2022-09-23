CREATE TABLE [dbo].[Packaging]
(
[pt_identity] [int] NOT NULL IDENTITY(1, 1),
[pt_part_number] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pt_length_inches] [numeric] (18, 0) NULL,
[pt_width_inches] [numeric] (18, 0) NULL,
[pt_height_inches] [numeric] (18, 0) NULL,
[pt_qty_per] [numeric] (18, 0) NULL,
[pt_weight_lbs] [numeric] (18, 0) NULL,
[pt_returnable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pt_palletized] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pt_pallet_type] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pt_estimate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pt_branch] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pt_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pt_date] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Packaging] TO [public]
GO
GRANT INSERT ON  [dbo].[Packaging] TO [public]
GO
GRANT SELECT ON  [dbo].[Packaging] TO [public]
GO
GRANT UPDATE ON  [dbo].[Packaging] TO [public]
GO
