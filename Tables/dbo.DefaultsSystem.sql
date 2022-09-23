CREATE TABLE [dbo].[DefaultsSystem]
(
[dfs_number] [int] NOT NULL IDENTITY(1, 1),
[dfs_window] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dfs_column] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dfs_value] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DefaultsSystem] TO [public]
GO
GRANT INSERT ON  [dbo].[DefaultsSystem] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DefaultsSystem] TO [public]
GO
GRANT SELECT ON  [dbo].[DefaultsSystem] TO [public]
GO
GRANT UPDATE ON  [dbo].[DefaultsSystem] TO [public]
GO
