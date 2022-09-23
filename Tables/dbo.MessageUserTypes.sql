CREATE TABLE [dbo].[MessageUserTypes]
(
[Id] [smallint] NOT NULL IDENTITY(1, 1),
[Description] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageUserTypes] ADD CONSTRAINT [PK_MessageUserTypes] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MessageUserTypes] TO [public]
GO
GRANT INSERT ON  [dbo].[MessageUserTypes] TO [public]
GO
GRANT SELECT ON  [dbo].[MessageUserTypes] TO [public]
GO
GRANT UPDATE ON  [dbo].[MessageUserTypes] TO [public]
GO
