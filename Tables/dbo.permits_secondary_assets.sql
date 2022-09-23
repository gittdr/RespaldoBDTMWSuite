CREATE TABLE [dbo].[permits_secondary_assets]
(
[psa_id] [int] NOT NULL IDENTITY(1, 1),
[p_id] [int] NOT NULL,
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[psa_max_gvw] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[permits_secondary_assets] ADD CONSTRAINT [pk_psa_id] PRIMARY KEY CLUSTERED ([psa_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[permits_secondary_assets] ADD CONSTRAINT [uk_permits_secondary_assets] UNIQUE NONCLUSTERED ([p_id], [asgn_type], [asgn_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[permits_secondary_assets] TO [public]
GO
GRANT INSERT ON  [dbo].[permits_secondary_assets] TO [public]
GO
GRANT SELECT ON  [dbo].[permits_secondary_assets] TO [public]
GO
GRANT UPDATE ON  [dbo].[permits_secondary_assets] TO [public]
GO
