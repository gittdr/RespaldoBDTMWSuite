CREATE TABLE [dbo].[transf_UserBranches]
(
[brn_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[transf_user_id] [int] NOT NULL,
[create_dt] [datetime] NOT NULL CONSTRAINT [DF_transf_UserBranches_create_dt] DEFAULT (((1)/(1))/(1900)),
[edit_dt] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[transf_UserBranches] ADD CONSTRAINT [PK_transf_UserBranches] PRIMARY KEY CLUSTERED ([brn_id], [transf_user_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[transf_UserBranches] TO [public]
GO
GRANT INSERT ON  [dbo].[transf_UserBranches] TO [public]
GO
GRANT SELECT ON  [dbo].[transf_UserBranches] TO [public]
GO
GRANT UPDATE ON  [dbo].[transf_UserBranches] TO [public]
GO
