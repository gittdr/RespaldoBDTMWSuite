CREATE TABLE [dbo].[PeopleNetCompany]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[CID] [int] NOT NULL,
[PeopleNetUrl] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PeopleNetKey] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PeopleNetCompany] ADD CONSTRAINT [pk_PeopleNetCompany] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PeopleNetCompany] TO [public]
GO
GRANT INSERT ON  [dbo].[PeopleNetCompany] TO [public]
GO
GRANT REFERENCES ON  [dbo].[PeopleNetCompany] TO [public]
GO
GRANT SELECT ON  [dbo].[PeopleNetCompany] TO [public]
GO
GRANT UPDATE ON  [dbo].[PeopleNetCompany] TO [public]
GO
