CREATE TABLE [dbo].[MobileCommMessageProcessLog]
(
[ProcessLogGuid] [uniqueidentifier] NOT NULL,
[MessageId] [bigint] NOT NULL,
[StartDate] [datetime] NOT NULL CONSTRAINT [df_MobileCommMessageProcessLog_StartDate] DEFAULT (getdate()),
[EndDate] [datetime] NULL,
[ProcessLogId] [bigint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageProcessLog] ADD CONSTRAINT [PK_MobileCommMessageProcessLog] PRIMARY KEY CLUSTERED ([ProcessLogId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_MobileCommMessageProcessLog_MessageId] ON [dbo].[MobileCommMessageProcessLog] ([MessageId]) INCLUDE ([EndDate]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_MobileCommMessageProcessLog_ProcessLogGuid] ON [dbo].[MobileCommMessageProcessLog] ([ProcessLogGuid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageProcessLog] ADD CONSTRAINT [FK_MobileCommMessageProcessLog_MobileCommMessageInstance_MessageId] FOREIGN KEY ([MessageId]) REFERENCES [dbo].[MobileCommMessage] ([MessageId]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[MobileCommMessageProcessLog] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommMessageProcessLog] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommMessageProcessLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommMessageProcessLog] TO [public]
GO
