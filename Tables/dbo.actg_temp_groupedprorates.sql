CREATE TABLE [dbo].[actg_temp_groupedprorates]
(
[sp_id] [int] NULL,
[gpr_identity] [int] NOT NULL IDENTITY(1, 1),
[cht_allocation_method] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_allocation_criteria] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_allocation_data] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_allocation_groupby] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prorate_quantity] [float] NULL,
[prorate_minlgh] [int] NULL,
[prorate_rate] [money] NULL,
[prorate_amount] [money] NULL,
[prorate_sequence] [int] NULL,
[prorate_item] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[actg_temp_groupedprorates] ADD CONSTRAINT [AutoPK_actg_temp_groupedprorates] PRIMARY KEY CLUSTERED ([gpr_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_actg_temp_groupedprorates_spid] ON [dbo].[actg_temp_groupedprorates] ([sp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[actg_temp_groupedprorates] TO [public]
GO
GRANT INSERT ON  [dbo].[actg_temp_groupedprorates] TO [public]
GO
GRANT REFERENCES ON  [dbo].[actg_temp_groupedprorates] TO [public]
GO
GRANT SELECT ON  [dbo].[actg_temp_groupedprorates] TO [public]
GO
GRANT UPDATE ON  [dbo].[actg_temp_groupedprorates] TO [public]
GO
