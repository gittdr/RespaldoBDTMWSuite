CREATE TABLE [dbo].[associate_branch]
(
[brn_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[brn_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payto_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[associate_branch] ADD CONSTRAINT [associate_branch_pk] PRIMARY KEY CLUSTERED ([brn_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[associate_branch] TO [public]
GO
GRANT INSERT ON  [dbo].[associate_branch] TO [public]
GO
GRANT SELECT ON  [dbo].[associate_branch] TO [public]
GO
GRANT UPDATE ON  [dbo].[associate_branch] TO [public]
GO
