CREATE TABLE [dbo].[asset_alias]
(
[alias_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[alias_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[asset_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[asset_alias] TO [public]
GO
GRANT INSERT ON  [dbo].[asset_alias] TO [public]
GO
GRANT REFERENCES ON  [dbo].[asset_alias] TO [public]
GO
GRANT SELECT ON  [dbo].[asset_alias] TO [public]
GO
GRANT UPDATE ON  [dbo].[asset_alias] TO [public]
GO
