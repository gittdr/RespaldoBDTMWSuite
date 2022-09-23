CREATE TABLE [dbo].[MessageUsers]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Email] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateCreated] [smalldatetime] NOT NULL,
[DateLastUpdated] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageUsers] ADD CONSTRAINT [PK_MessageUsers] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MessageUsers] TO [public]
GO
GRANT INSERT ON  [dbo].[MessageUsers] TO [public]
GO
GRANT SELECT ON  [dbo].[MessageUsers] TO [public]
GO
GRANT UPDATE ON  [dbo].[MessageUsers] TO [public]
GO
