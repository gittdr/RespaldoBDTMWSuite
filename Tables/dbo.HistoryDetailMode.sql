CREATE TABLE [dbo].[HistoryDetailMode]
(
[HistoryDetailModeId] [int] NOT NULL,
[Mode] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HistoryDetailMode] ADD CONSTRAINT [PK_HistoryDetailMode] PRIMARY KEY CLUSTERED ([HistoryDetailModeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[HistoryDetailMode] TO [public]
GO
GRANT INSERT ON  [dbo].[HistoryDetailMode] TO [public]
GO
GRANT REFERENCES ON  [dbo].[HistoryDetailMode] TO [public]
GO
GRANT SELECT ON  [dbo].[HistoryDetailMode] TO [public]
GO
GRANT UPDATE ON  [dbo].[HistoryDetailMode] TO [public]
GO
