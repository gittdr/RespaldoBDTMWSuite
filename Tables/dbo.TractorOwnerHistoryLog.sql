CREATE TABLE [dbo].[TractorOwnerHistoryLog]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[trc_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[previous_owner] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[new_owner] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[change_user] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[change_date] [datetime] NULL,
[change_reason] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TractorOwnerHistoryLog_trc_id] ON [dbo].[TractorOwnerHistoryLog] ([trc_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TractorOwnerHistoryLog] TO [public]
GO
GRANT INSERT ON  [dbo].[TractorOwnerHistoryLog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TractorOwnerHistoryLog] TO [public]
GO
GRANT SELECT ON  [dbo].[TractorOwnerHistoryLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[TractorOwnerHistoryLog] TO [public]
GO
