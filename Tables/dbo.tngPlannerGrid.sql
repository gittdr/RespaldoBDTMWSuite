CREATE TABLE [dbo].[tngPlannerGrid]
(
[grid_id] [int] NOT NULL IDENTITY(1, 1),
[grid_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[grid_parent_id] [int] NOT NULL,
[grid_authlevel] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[grid_authvalue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[grid_rollinchildren] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[grid_datasource] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[grid_methodname] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tngPlannerGrid] ADD CONSTRAINT [PK__tngPlannerGrid__16C4A489] PRIMARY KEY CLUSTERED ([grid_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [tngPlannerGrid_grid_name] ON [dbo].[tngPlannerGrid] ([grid_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tngPlannerGrid] TO [public]
GO
GRANT INSERT ON  [dbo].[tngPlannerGrid] TO [public]
GO
GRANT SELECT ON  [dbo].[tngPlannerGrid] TO [public]
GO
GRANT UPDATE ON  [dbo].[tngPlannerGrid] TO [public]
GO
