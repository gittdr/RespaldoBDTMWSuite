CREATE TABLE [dbo].[TIMessageQueue]
(
[mq_id] [int] NOT NULL IDENTITY(1, 1),
[mq_source] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mq_customerid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mq_description] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mq_status] [int] NULL,
[am_id] [int] NULL,
[mq_tripid] [int] NULL,
[mq_alk_tripid] [int] NULL,
[msg_sn] [int] NULL,
[mq_dateread] [datetime] NULL,
[mq_dateprocessed] [datetime] NULL,
[mq_error] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logId] [int] NULL,
[mq_createdby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TIMessageQueue_mq_createdby] DEFAULT (suser_name()),
[mq_createdon] [datetime] NULL CONSTRAINT [DF_TIMessageQueue_mq_createdOn] DEFAULT (getdate()),
[mq_lastupdatedby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mq_lastupdatedon] [datetime] NULL,
[mq_lastupdateapp] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mq_errormgs] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mq_errorsource] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TIMessageQueue] ADD CONSTRAINT [PK_TIMessageQueue] PRIMARY KEY CLUSTERED ([mq_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TIMessageQueue] ADD CONSTRAINT [fk_ti_action] FOREIGN KEY ([am_id]) REFERENCES [dbo].[TIActionMap] ([am_id])
GO
GRANT DELETE ON  [dbo].[TIMessageQueue] TO [public]
GO
GRANT INSERT ON  [dbo].[TIMessageQueue] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TIMessageQueue] TO [public]
GO
GRANT SELECT ON  [dbo].[TIMessageQueue] TO [public]
GO
GRANT UPDATE ON  [dbo].[TIMessageQueue] TO [public]
GO
