CREATE TABLE [dbo].[MessageUserType]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[UserId] [int] NOT NULL,
[TypeId] [smallint] NOT NULL,
[UserTypeId] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageUserType] ADD CONSTRAINT [PK_MessageUserType] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageUserType] ADD CONSTRAINT [FK_MessageUserType_MessageUsers] FOREIGN KEY ([UserId]) REFERENCES [dbo].[MessageUsers] ([Id])
GO
ALTER TABLE [dbo].[MessageUserType] ADD CONSTRAINT [FK_MessageUserType_MessageUserTypes] FOREIGN KEY ([TypeId]) REFERENCES [dbo].[MessageUserTypes] ([Id])
GO
GRANT DELETE ON  [dbo].[MessageUserType] TO [public]
GO
GRANT INSERT ON  [dbo].[MessageUserType] TO [public]
GO
GRANT SELECT ON  [dbo].[MessageUserType] TO [public]
GO
GRANT UPDATE ON  [dbo].[MessageUserType] TO [public]
GO
