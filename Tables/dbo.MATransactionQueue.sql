CREATE TABLE [dbo].[MATransactionQueue]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[transaction_id] [bigint] NOT NULL,
[transacion_reqest_dt] [datetime] NOT NULL,
[usr_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[notification_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[notification_status_dt] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MATransactionQueue] ADD CONSTRAINT [pk_MATransactionQueueId] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_MATransactionQueue_StatusAndDate] ON [dbo].[MATransactionQueue] ([notification_status], [notification_status_dt]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MATransactionQueue] TO [public]
GO
GRANT INSERT ON  [dbo].[MATransactionQueue] TO [public]
GO
GRANT SELECT ON  [dbo].[MATransactionQueue] TO [public]
GO
GRANT UPDATE ON  [dbo].[MATransactionQueue] TO [public]
GO
