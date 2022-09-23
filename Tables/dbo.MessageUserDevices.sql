CREATE TABLE [dbo].[MessageUserDevices]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[UserId] [int] NOT NULL,
[DeviceId] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageUserDevices] ADD CONSTRAINT [PK_MessageUserDevices] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageUserDevices] ADD CONSTRAINT [FK_MessageUserDevices_MessageUsers] FOREIGN KEY ([UserId]) REFERENCES [dbo].[MessageUsers] ([Id])
GO
GRANT DELETE ON  [dbo].[MessageUserDevices] TO [public]
GO
GRANT INSERT ON  [dbo].[MessageUserDevices] TO [public]
GO
GRANT SELECT ON  [dbo].[MessageUserDevices] TO [public]
GO
GRANT UPDATE ON  [dbo].[MessageUserDevices] TO [public]
GO
