CREATE TABLE [dbo].[transf_UserGroups]
(
[group_id] [int] NOT NULL,
[transf_user_id] [int] NOT NULL,
[create_dt] [datetime] NOT NULL CONSTRAINT [DF_transf_UserGroups_create_dt] DEFAULT (((1)/(1))/(1900)),
[edit_dt] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[transf_UserGroups] ADD CONSTRAINT [PK_transf_UserGroups] PRIMARY KEY CLUSTERED ([group_id], [transf_user_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[transf_UserGroups] TO [public]
GO
GRANT INSERT ON  [dbo].[transf_UserGroups] TO [public]
GO
GRANT SELECT ON  [dbo].[transf_UserGroups] TO [public]
GO
GRANT UPDATE ON  [dbo].[transf_UserGroups] TO [public]
GO
