CREATE TABLE [dbo].[Workflow_QueueData]
(
[QueueData_ID] [int] NOT NULL IDENTITY(1, 1),
[QueueData_ReadStatus] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QueueData_WorkflowID] [int] NOT NULL,
[QueueData_AssignedQueue] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_QueueData] ADD CONSTRAINT [PK__Workflow__799B1D13410CF840] PRIMARY KEY CLUSTERED ([QueueData_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_QueueData] ADD CONSTRAINT [FK__Workflow___Queue__7F75BD9B] FOREIGN KEY ([QueueData_WorkflowID]) REFERENCES [dbo].[Workflow] ([WorkFlow_ID])
GO
ALTER TABLE [dbo].[Workflow_QueueData] ADD CONSTRAINT [FK__Workflow___Queue__0069E1D4] FOREIGN KEY ([QueueData_AssignedQueue]) REFERENCES [dbo].[Workflow_Queues] ([Queue_ID])
GO
