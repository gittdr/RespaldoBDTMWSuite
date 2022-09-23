CREATE TABLE [dbo].[HistoryDetail]
(
[HistoryDetailId] [bigint] NOT NULL IDENTITY(1, 1),
[HistoryConfigurationId] [int] NOT NULL,
[HistoryDetailRecordTypeId] [int] NOT NULL,
[Artifact] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ArtifactKey] [bigint] NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[CreatedByUserId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HistoryDetail] ADD CONSTRAINT [PK_HistoryDetail] PRIMARY KEY CLUSTERED ([HistoryDetailId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_HistoryDetail_ArtifactKey] ON [dbo].[HistoryDetail] ([ArtifactKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_HistoryDetail_HistoryDetailRecordTypeId] ON [dbo].[HistoryDetail] ([HistoryDetailRecordTypeId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HistoryDetail] ADD CONSTRAINT [FK_HistoryDetail_HistoryConfiguration] FOREIGN KEY ([HistoryConfigurationId]) REFERENCES [dbo].[HistoryConfiguration] ([HistoryConfigurationId])
GO
ALTER TABLE [dbo].[HistoryDetail] ADD CONSTRAINT [FK_HistoryDetail_HistoryDetailRecordType] FOREIGN KEY ([HistoryDetailRecordTypeId]) REFERENCES [dbo].[HistoryDetailRecordType] ([HistoryDetailRecordTypeId])
GO
ALTER TABLE [dbo].[HistoryDetail] ADD CONSTRAINT [FK_HistoryDetail_HistoryUserInformation] FOREIGN KEY ([CreatedByUserId]) REFERENCES [dbo].[HistoryUserInformation] ([HistoryUserInformationId])
GO
GRANT DELETE ON  [dbo].[HistoryDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[HistoryDetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[HistoryDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[HistoryDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[HistoryDetail] TO [public]
GO
