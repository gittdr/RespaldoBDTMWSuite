CREATE TABLE [dbo].[MR_ServerAndDatabaseAccess]
(
[ServerName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DatabaseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[MR_ServerAndDatabaseAccess] TO [public]
GO
