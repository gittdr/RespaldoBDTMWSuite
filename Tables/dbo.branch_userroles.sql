CREATE TABLE [dbo].[branch_userroles]
(
[bur_id] [int] NOT NULL IDENTITY(1, 1),
[bur_brn_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bur_user_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bur_role] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bur_default] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bur_userdefined1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bur_userdefined2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bur_userdefined3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bur_userdefined4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[branch_userroles] ADD CONSTRAINT [PK__branch_userroles__78F0B561] PRIMARY KEY CLUSTERED ([bur_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[branch_userroles] TO [public]
GO
GRANT INSERT ON  [dbo].[branch_userroles] TO [public]
GO
GRANT REFERENCES ON  [dbo].[branch_userroles] TO [public]
GO
GRANT SELECT ON  [dbo].[branch_userroles] TO [public]
GO
GRANT UPDATE ON  [dbo].[branch_userroles] TO [public]
GO
