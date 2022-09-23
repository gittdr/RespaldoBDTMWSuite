CREATE TABLE [dbo].[ph_parent_child_lglentity]
(
[phpcL_id] [int] NOT NULL IDENTITY(1, 1),
[phpcL_parentPH] [int] NULL,
[phpcL_parentLglEntity] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phpcL_childPH] [int] NULL,
[phpcL_childLglEntity] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ph_parent_child_lglentity] ADD CONSTRAINT [pk_phpcL_id] PRIMARY KEY CLUSTERED ([phpcL_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ph_parent_child_lglentity] TO [public]
GO
GRANT INSERT ON  [dbo].[ph_parent_child_lglentity] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ph_parent_child_lglentity] TO [public]
GO
GRANT SELECT ON  [dbo].[ph_parent_child_lglentity] TO [public]
GO
GRANT UPDATE ON  [dbo].[ph_parent_child_lglentity] TO [public]
GO
