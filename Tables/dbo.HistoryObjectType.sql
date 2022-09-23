CREATE TABLE [dbo].[HistoryObjectType]
(
[HistoryObjectTypeId] [int] NOT NULL,
[ObjectType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HistoryObjectType] ADD CONSTRAINT [PK_HistoryObjectType] PRIMARY KEY CLUSTERED ([HistoryObjectTypeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[HistoryObjectType] TO [public]
GO
GRANT INSERT ON  [dbo].[HistoryObjectType] TO [public]
GO
GRANT REFERENCES ON  [dbo].[HistoryObjectType] TO [public]
GO
GRANT SELECT ON  [dbo].[HistoryObjectType] TO [public]
GO
GRANT UPDATE ON  [dbo].[HistoryObjectType] TO [public]
GO
