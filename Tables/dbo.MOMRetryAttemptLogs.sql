CREATE TABLE [dbo].[MOMRetryAttemptLogs]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Ord_hdrnumber] [int] NOT NULL,
[currentRuncount] [int] NOT NULL,
[InitialRunTime] [datetime] NOT NULL,
[ErrorMessage] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecentRunTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MOMRetryAttemptLogs] ADD CONSTRAINT [pk_MoMRetryid] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [MOMRetryIdx] ON [dbo].[MOMRetryAttemptLogs] ([Ord_hdrnumber]) INCLUDE ([currentRuncount]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MOMRetryAttemptLogs] TO [public]
GO
GRANT INSERT ON  [dbo].[MOMRetryAttemptLogs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MOMRetryAttemptLogs] TO [public]
GO
GRANT SELECT ON  [dbo].[MOMRetryAttemptLogs] TO [public]
GO
GRANT UPDATE ON  [dbo].[MOMRetryAttemptLogs] TO [public]
GO
