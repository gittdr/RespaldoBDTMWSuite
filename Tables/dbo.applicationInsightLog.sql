CREATE TABLE [dbo].[applicationInsightLog]
(
[logId] [int] NOT NULL IDENTITY(1, 1),
[logType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[logDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[applicationInsightLog] ADD CONSTRAINT [pk_applicationInsightLog_logId] PRIMARY KEY CLUSTERED ([logId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[applicationInsightLog] TO [public]
GO
GRANT INSERT ON  [dbo].[applicationInsightLog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[applicationInsightLog] TO [public]
GO
GRANT SELECT ON  [dbo].[applicationInsightLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[applicationInsightLog] TO [public]
GO
