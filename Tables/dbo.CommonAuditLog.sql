CREATE TABLE [dbo].[CommonAuditLog]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Application] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsError] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[KeyData1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KeyData2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogMessage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LogDate] [datetime] NOT NULL,
[UserId] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CommonAuditLog] ADD CONSTRAINT [PK__CommonAuditLog__74794663] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_CommonAuditLog_Application_IsError_LogDate] ON [dbo].[CommonAuditLog] ([Application], [IsError], [LogDate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CommonAuditLog] TO [public]
GO
GRANT INSERT ON  [dbo].[CommonAuditLog] TO [public]
GO
GRANT SELECT ON  [dbo].[CommonAuditLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[CommonAuditLog] TO [public]
GO
