CREATE TABLE [dbo].[transf_users]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[user_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[first_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[def_brn_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[salt_value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hashed_pwd] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_type_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[def_screen] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_transf_users_status] DEFAULT ('Active'),
[email_addr] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_dt] [datetime] NOT NULL CONSTRAINT [DF_transf_users_create_dt] DEFAULT (((1)/(1))/(1900)),
[pwd_changed_dt] [datetime] NOT NULL CONSTRAINT [DF_transf_users_pwd_changed_dt] DEFAULT (((1)/(1))/(1900)),
[usr_branch_list] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_group_list] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_company_list] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE TRIGGER [dbo].[dt_transf_users] ON [dbo].[transf_users] FOR DELETE AS 
/* EXECUTE timerins "dt_transf_users", "START" */
set nocount on
	delete transf_UserGroups 
		from transf_UserGroups g, deleted d
		where g.transf_user_id = d.id

	delete transf_UserBranches 
		from transf_UserBranches b, deleted d
		where b.transf_user_id = d.id

	delete transf_user_cust_modules 
		from transf_user_cust_modules m, deleted d
		where m.transf_user_id = d.id
	
	-- SR 31989
	delete transf_RMFilter
		from transf_RMFilter r, deleted d
		where r.transf_user_id = d.id

return
SET NOCOUNT OFF

GO
ALTER TABLE [dbo].[transf_users] ADD CONSTRAINT [PK_transf_users] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[transf_users] ADD CONSTRAINT [UK_transf_users_user_id] UNIQUE NONCLUSTERED ([user_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[transf_users] TO [public]
GO
GRANT INSERT ON  [dbo].[transf_users] TO [public]
GO
GRANT SELECT ON  [dbo].[transf_users] TO [public]
GO
GRANT UPDATE ON  [dbo].[transf_users] TO [public]
GO
