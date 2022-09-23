CREATE TABLE [dbo].[SAFETYLOG]
(
[slog_ID] [int] NOT NULL IDENTITY(1, 1),
[srp_ID] [int] NOT NULL,
[slog_Date] [datetime] NOT NULL,
[slog_UpdateBy] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[slog_action] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_slogID] ON [dbo].[SAFETYLOG] ([slog_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SAFETYLOG] TO [public]
GO
GRANT INSERT ON  [dbo].[SAFETYLOG] TO [public]
GO
GRANT REFERENCES ON  [dbo].[SAFETYLOG] TO [public]
GO
GRANT SELECT ON  [dbo].[SAFETYLOG] TO [public]
GO
GRANT UPDATE ON  [dbo].[SAFETYLOG] TO [public]
GO
