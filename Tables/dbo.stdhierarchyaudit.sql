CREATE TABLE [dbo].[stdhierarchyaudit]
(
[stha_id] [int] NOT NULL IDENTITY(1, 1),
[sth_id] [int] NOT NULL,
[stha_action] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stha_update_dt] [datetime] NULL,
[stha_update_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stha_update_field] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stha_original_value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stha_new_value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[stdhierarchyaudit] ADD CONSTRAINT [pk_stdhierarchyaudit_stha_id] PRIMARY KEY CLUSTERED ([stha_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_stdhierarchyaudit_sth_id] ON [dbo].[stdhierarchyaudit] ([sth_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[stdhierarchyaudit] TO [public]
GO
GRANT INSERT ON  [dbo].[stdhierarchyaudit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[stdhierarchyaudit] TO [public]
GO
GRANT SELECT ON  [dbo].[stdhierarchyaudit] TO [public]
GO
GRANT UPDATE ON  [dbo].[stdhierarchyaudit] TO [public]
GO
