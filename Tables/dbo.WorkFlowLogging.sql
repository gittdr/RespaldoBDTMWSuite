CREATE TABLE [dbo].[WorkFlowLogging]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[WorkflowName] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Updatedtime] [datetime] NOT NULL CONSTRAINT [DF_WorkFlowLogging_Updatedtime] DEFAULT (getdate()),
[Loginformation] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ActivityID] [int] NOT NULL CONSTRAINT [DF__WorkFlowL__Activ__36680272] DEFAULT ((999)),
[TemplateID] [int] NOT NULL,
[InstanceID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkFlowLogging] ADD CONSTRAINT [PK_WorkFlowLogging] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkFlowLogging] ADD CONSTRAINT [fk_Workflow_Logging] FOREIGN KEY ([TemplateID]) REFERENCES [dbo].[Workflow_Client_Templates] ([TemplateId])
GO
GRANT DELETE ON  [dbo].[WorkFlowLogging] TO [public]
GO
GRANT INSERT ON  [dbo].[WorkFlowLogging] TO [public]
GO
GRANT REFERENCES ON  [dbo].[WorkFlowLogging] TO [public]
GO
GRANT SELECT ON  [dbo].[WorkFlowLogging] TO [public]
GO
GRANT UPDATE ON  [dbo].[WorkFlowLogging] TO [public]
GO
