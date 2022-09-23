CREATE TABLE [dbo].[PeopleNetLink]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[PfmCompanyId] [int] NOT NULL,
[TmwUser] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PfmId] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TabId] [int] NULL,
[TabName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PeopleNetLink] ADD CONSTRAINT [pk_PeopleNetLink] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PeopleNetLink] ADD CONSTRAINT [fk_PeopleNetLink_Id] FOREIGN KEY ([PfmCompanyId]) REFERENCES [dbo].[PeopleNetCompany] ([Id]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[PeopleNetLink] TO [public]
GO
GRANT INSERT ON  [dbo].[PeopleNetLink] TO [public]
GO
GRANT REFERENCES ON  [dbo].[PeopleNetLink] TO [public]
GO
GRANT SELECT ON  [dbo].[PeopleNetLink] TO [public]
GO
GRANT UPDATE ON  [dbo].[PeopleNetLink] TO [public]
GO
