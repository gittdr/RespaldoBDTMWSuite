CREATE TABLE [dbo].[rail_customers]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rcu_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rcu_equipmconfiguration] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rcu_destination_city] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rail_customers] ADD CONSTRAINT [pk_rail_customers] PRIMARY KEY CLUSTERED ([cmp_id], [rcu_id], [rcu_equipmconfiguration], [rcu_destination_city]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[rail_customers] TO [public]
GO
GRANT INSERT ON  [dbo].[rail_customers] TO [public]
GO
GRANT REFERENCES ON  [dbo].[rail_customers] TO [public]
GO
GRANT SELECT ON  [dbo].[rail_customers] TO [public]
GO
GRANT UPDATE ON  [dbo].[rail_customers] TO [public]
GO
