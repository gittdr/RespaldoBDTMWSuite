CREATE TABLE [dbo].[HistoryDetailRecordType]
(
[HistoryDetailRecordTypeId] [int] NOT NULL,
[RecordType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HistoryDetailRecordType] ADD CONSTRAINT [PK_HistoryDetailRecordType] PRIMARY KEY CLUSTERED ([HistoryDetailRecordTypeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[HistoryDetailRecordType] TO [public]
GO
GRANT INSERT ON  [dbo].[HistoryDetailRecordType] TO [public]
GO
GRANT REFERENCES ON  [dbo].[HistoryDetailRecordType] TO [public]
GO
GRANT SELECT ON  [dbo].[HistoryDetailRecordType] TO [public]
GO
GRANT UPDATE ON  [dbo].[HistoryDetailRecordType] TO [public]
GO
