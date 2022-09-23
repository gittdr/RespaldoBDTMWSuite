CREATE TABLE [dbo].[company_InvSrvChangeLog]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LogDate] [datetime] NOT NULL,
[UserID] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_InvSrvMode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_InvSrvReleaseOnly] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_ForecastBatch] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_SalesHistoryBatch] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_InvSrvChangeLog] ADD CONSTRAINT [PK__company_InvSrvCh__5675154A] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_company_InvSrvChangeLog_cmp_id_LogDate] ON [dbo].[company_InvSrvChangeLog] ([cmp_id], [LogDate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_InvSrvChangeLog] TO [public]
GO
GRANT INSERT ON  [dbo].[company_InvSrvChangeLog] TO [public]
GO
GRANT SELECT ON  [dbo].[company_InvSrvChangeLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_InvSrvChangeLog] TO [public]
GO
