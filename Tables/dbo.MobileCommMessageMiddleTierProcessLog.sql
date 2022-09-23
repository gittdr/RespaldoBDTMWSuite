CREATE TABLE [dbo].[MobileCommMessageMiddleTierProcessLog]
(
[MiddleTierProcessLogId] [bigint] NOT NULL IDENTITY(1, 1),
[MiddleTierProcessLogGuid] [uniqueidentifier] NOT NULL,
[ProcessLogId] [bigint] NOT NULL,
[MessageId] [bigint] NOT NULL,
[MiddleTierMethod] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MiddleTierData] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartDate] [datetime] NOT NULL CONSTRAINT [df_MobileCommMessageMiddleTierProcessLog_StartDate] DEFAULT (getdate()),
[EndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageMiddleTierProcessLog] ADD CONSTRAINT [PK_MobileCommMessageMiddleTierProcessLog] PRIMARY KEY CLUSTERED ([MiddleTierProcessLogId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_MobileCommMessageMiddleTierProcessLog_MessageId] ON [dbo].[MobileCommMessageMiddleTierProcessLog] ([MessageId]) INCLUDE ([EndDate]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_MobileCommMessageMiddleTierProcessLog_MiddleTierProcessLogGuid] ON [dbo].[MobileCommMessageMiddleTierProcessLog] ([MiddleTierProcessLogGuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_MobileCommMessageMiddleTierProcessLog_ProcessLogId] ON [dbo].[MobileCommMessageMiddleTierProcessLog] ([ProcessLogId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageMiddleTierProcessLog] ADD CONSTRAINT [FK_MobileCommMessageMiddleTierProcessLog_MobileCommMessageInstance_MessageId] FOREIGN KEY ([MessageId]) REFERENCES [dbo].[MobileCommMessage] ([MessageId]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MobileCommMessageMiddleTierProcessLog] ADD CONSTRAINT [FK_MobileCommMessageMiddleTierProcessLog_MobileCommMessageProcessLog_ProcessLogId] FOREIGN KEY ([ProcessLogId]) REFERENCES [dbo].[MobileCommMessageProcessLog] ([ProcessLogId])
GO
GRANT DELETE ON  [dbo].[MobileCommMessageMiddleTierProcessLog] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommMessageMiddleTierProcessLog] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommMessageMiddleTierProcessLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommMessageMiddleTierProcessLog] TO [public]
GO
