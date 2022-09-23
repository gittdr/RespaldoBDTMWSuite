CREATE TABLE [dbo].[actg_temp_prorate]
(
[sp_id] [int] NULL,
[cht_allocation_method] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_allocation_criteria] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_allocation_data] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[section_quantity] [float] NULL,
[lgh_number] [int] NULL,
[section_item] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[actg_temp_prorate_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[actg_temp_prorate] ADD CONSTRAINT [prkey_actg_temp_prorate] PRIMARY KEY NONCLUSTERED ([actg_temp_prorate_ident]) WITH (FILLFACTOR=100, STATISTICS_NORECOMPUTE=ON) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [clix_atp] ON [dbo].[actg_temp_prorate] ([sp_id]) WITH (FILLFACTOR=70, STATISTICS_NORECOMPUTE=ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_actg_temp_prorate_spid] ON [dbo].[actg_temp_prorate] ([sp_id]) WITH (STATISTICS_NORECOMPUTE=ON) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[actg_temp_prorate] TO [public]
GO
GRANT INSERT ON  [dbo].[actg_temp_prorate] TO [public]
GO
GRANT REFERENCES ON  [dbo].[actg_temp_prorate] TO [public]
GO
GRANT SELECT ON  [dbo].[actg_temp_prorate] TO [public]
GO
GRANT UPDATE ON  [dbo].[actg_temp_prorate] TO [public]
GO
