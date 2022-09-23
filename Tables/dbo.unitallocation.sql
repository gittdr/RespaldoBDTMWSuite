CREATE TABLE [dbo].[unitallocation]
(
[ualloc_id] [int] NOT NULL IDENTITY(1, 1),
[unit_number] [char] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[first_effective_date] [datetime] NOT NULL,
[last_effective_date] [datetime] NOT NULL,
[branch_number] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[source_system] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[create_module] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[create_date] [datetime] NOT NULL,
[create_user] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[update_module] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[update_date] [datetime] NOT NULL,
[update_user] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[unitallocation] ADD CONSTRAINT [unitallocation_pk] PRIMARY KEY CLUSTERED ([ualloc_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[unitallocation] TO [public]
GO
GRANT INSERT ON  [dbo].[unitallocation] TO [public]
GO
GRANT SELECT ON  [dbo].[unitallocation] TO [public]
GO
GRANT UPDATE ON  [dbo].[unitallocation] TO [public]
GO
