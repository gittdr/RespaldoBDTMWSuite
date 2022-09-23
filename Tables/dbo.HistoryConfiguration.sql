CREATE TABLE [dbo].[HistoryConfiguration]
(
[HistoryConfigurationId] [int] NOT NULL IDENTITY(1, 1),
[HistoryObjectTypeId] [int] NOT NULL,
[HistoryDetailModeId] [int] NOT NULL,
[RefreshIncrement] [int] NOT NULL,
[CheckPointIncrement] [int] NOT NULL,
[PurgeOverrideSize] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HistoryConfiguration] ADD CONSTRAINT [PK_HistoryConfiguration] PRIMARY KEY CLUSTERED ([HistoryConfigurationId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_HistoryConfiguration_HistoryObjectTypeId] ON [dbo].[HistoryConfiguration] ([HistoryObjectTypeId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HistoryConfiguration] ADD CONSTRAINT [UC_HistoryObjectTypeId] UNIQUE NONCLUSTERED ([HistoryObjectTypeId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HistoryConfiguration] ADD CONSTRAINT [FK_HistoryConfiguration_HistoryDetailMode] FOREIGN KEY ([HistoryDetailModeId]) REFERENCES [dbo].[HistoryDetailMode] ([HistoryDetailModeId])
GO
ALTER TABLE [dbo].[HistoryConfiguration] ADD CONSTRAINT [FK_HistoryConfiguration_HistoryObjectType] FOREIGN KEY ([HistoryObjectTypeId]) REFERENCES [dbo].[HistoryObjectType] ([HistoryObjectTypeId])
GO
GRANT DELETE ON  [dbo].[HistoryConfiguration] TO [public]
GO
GRANT INSERT ON  [dbo].[HistoryConfiguration] TO [public]
GO
GRANT REFERENCES ON  [dbo].[HistoryConfiguration] TO [public]
GO
GRANT SELECT ON  [dbo].[HistoryConfiguration] TO [public]
GO
GRANT UPDATE ON  [dbo].[HistoryConfiguration] TO [public]
GO
