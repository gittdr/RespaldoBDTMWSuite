CREATE TABLE [dbo].[ph_parent_child_branch]
(
[phpcb_id] [int] NOT NULL IDENTITY(1, 1),
[phpcb_parentPH] [int] NULL,
[phpcb_parentBranch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phpcb_childPH] [int] NULL,
[phpcb_childBranch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ph_parent_child_branch] ADD CONSTRAINT [pk_phpcb_id] PRIMARY KEY CLUSTERED ([phpcb_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ph_parent_child_branch] TO [public]
GO
GRANT INSERT ON  [dbo].[ph_parent_child_branch] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ph_parent_child_branch] TO [public]
GO
GRANT SELECT ON  [dbo].[ph_parent_child_branch] TO [public]
GO
GRANT UPDATE ON  [dbo].[ph_parent_child_branch] TO [public]
GO
