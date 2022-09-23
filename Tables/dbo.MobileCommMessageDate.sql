CREATE TABLE [dbo].[MobileCommMessageDate]
(
[MessageDateId] [bigint] NOT NULL IDENTITY(1, 1),
[MessageId] [bigint] NOT NULL,
[MessageDateTypeId] [int] NOT NULL,
[EventDate] [datetimeoffset] NOT NULL,
[ModuleId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageDate] ADD CONSTRAINT [PK_MobileCommMessageDate] PRIMARY KEY CLUSTERED ([MessageDateId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_MobileCommMessageDate_EventDate_MessageDateTypeId] ON [dbo].[MobileCommMessageDate] ([EventDate] DESC, [MessageDateTypeId]) INCLUDE ([MessageId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_MobileCommMessageDate_EventDate_MessageId] ON [dbo].[MobileCommMessageDate] ([EventDate], [MessageId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_MobileCommMessageDate_MessageId_MessageDateTypeId] ON [dbo].[MobileCommMessageDate] ([MessageId], [MessageDateTypeId], [ModuleId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageDate] ADD CONSTRAINT [FK_MobileCommMessageDate_MessageDateTypeId] FOREIGN KEY ([MessageDateTypeId]) REFERENCES [dbo].[MobileCommMessageDateType] ([MessageDateTypeId])
GO
ALTER TABLE [dbo].[MobileCommMessageDate] ADD CONSTRAINT [FK_MobileCommMessageDate_MessageId] FOREIGN KEY ([MessageId]) REFERENCES [dbo].[MobileCommMessage] ([MessageId]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MobileCommMessageDate] ADD CONSTRAINT [FK_MobileCommMessageDate_MobileCommMessageDateModuleType_ModuleId] FOREIGN KEY ([ModuleId]) REFERENCES [dbo].[MobileCommMessageDateModuleType] ([ModuleId])
GO
GRANT DELETE ON  [dbo].[MobileCommMessageDate] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommMessageDate] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommMessageDate] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommMessageDate] TO [public]
GO
