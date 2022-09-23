CREATE TABLE [dbo].[dx_QueueEvent]
(
[qev_Ident] [int] NOT NULL IDENTITY(1, 1),
[que_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[qev_Action] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[qev_Time] [datetime] NULL,
[qev_Detail] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_QueueEvent] ADD CONSTRAINT [PK_dx_Queue_Event_Log] PRIMARY KEY CLUSTERED ([qev_Ident]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_QueueEvent] ADD CONSTRAINT [FK_dx_QueueEvent_que_ID] FOREIGN KEY ([que_ID]) REFERENCES [dbo].[dx_Queues] ([que_ID])
GO
GRANT DELETE ON  [dbo].[dx_QueueEvent] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_QueueEvent] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_QueueEvent] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_QueueEvent] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_QueueEvent] TO [public]
GO
