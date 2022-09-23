CREATE TABLE [dbo].[fueleconomy3]
(
[fec_region] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fec_engine] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fec_num_axles] [int] NOT NULL,
[fec_min_weight] [decimal] (7, 3) NOT NULL,
[fec_max_weight] [decimal] (7, 3) NOT NULL,
[fec_mpg_loaded] [decimal] (7, 3) NOT NULL,
[fec_mpg_empty] [decimal] (7, 3) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fueleconomy3] ADD CONSTRAINT [PK__fueleconomy__6DDE91D4] PRIMARY KEY CLUSTERED ([fec_region], [fec_engine], [fec_num_axles], [fec_min_weight], [fec_max_weight]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[fueleconomy3] TO [public]
GO
GRANT INSERT ON  [dbo].[fueleconomy3] TO [public]
GO
GRANT SELECT ON  [dbo].[fueleconomy3] TO [public]
GO
GRANT UPDATE ON  [dbo].[fueleconomy3] TO [public]
GO
