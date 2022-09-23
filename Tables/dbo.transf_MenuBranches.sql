CREATE TABLE [dbo].[transf_MenuBranches]
(
[menu_id] [int] NOT NULL,
[brn_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[create_dt] [datetime] NOT NULL CONSTRAINT [DF_transf_MenuBranches_create_dt] DEFAULT (((1)/(1))/(1900)),
[edit_dt] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[transf_MenuBranches] ADD CONSTRAINT [PK_transf_MenuBranches] PRIMARY KEY CLUSTERED ([menu_id], [brn_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[transf_MenuBranches] TO [public]
GO
GRANT INSERT ON  [dbo].[transf_MenuBranches] TO [public]
GO
GRANT SELECT ON  [dbo].[transf_MenuBranches] TO [public]
GO
GRANT UPDATE ON  [dbo].[transf_MenuBranches] TO [public]
GO
