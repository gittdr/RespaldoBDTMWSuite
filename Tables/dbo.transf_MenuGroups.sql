CREATE TABLE [dbo].[transf_MenuGroups]
(
[menu_id] [int] NOT NULL,
[group_id] [int] NOT NULL,
[create_dt] [datetime] NOT NULL CONSTRAINT [DF_transf_MenuGroups_create_dt] DEFAULT (((1)/(1))/(1900)),
[edit_dt] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[transf_MenuGroups] ADD CONSTRAINT [PK_transf_MenuGroups] PRIMARY KEY CLUSTERED ([menu_id], [group_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[transf_MenuGroups] TO [public]
GO
GRANT INSERT ON  [dbo].[transf_MenuGroups] TO [public]
GO
GRANT SELECT ON  [dbo].[transf_MenuGroups] TO [public]
GO
GRANT UPDATE ON  [dbo].[transf_MenuGroups] TO [public]
GO
