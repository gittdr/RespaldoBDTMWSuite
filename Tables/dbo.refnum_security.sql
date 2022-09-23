CREATE TABLE [dbo].[refnum_security]
(
[rest_id] [int] NOT NULL IDENTITY(1, 1),
[rest_perm] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rest_user_group_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[refnum_security] TO [public]
GO
GRANT INSERT ON  [dbo].[refnum_security] TO [public]
GO
GRANT REFERENCES ON  [dbo].[refnum_security] TO [public]
GO
GRANT SELECT ON  [dbo].[refnum_security] TO [public]
GO
GRANT UPDATE ON  [dbo].[refnum_security] TO [public]
GO
