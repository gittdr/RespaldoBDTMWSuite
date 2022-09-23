CREATE TABLE [dbo].[Workflow_Client_Instances]
(
[WorkFlowID] [int] NOT NULL IDENTITY(1, 1),
[TemplateId] [int] NOT NULL,
[Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Workflow___Statu__42CDD957] DEFAULT ('Active'),
[WorkflowStartTime] [datetime] NULL,
[WorkflowEndTime] [datetime] NULL,
[Entityvalue] [int] NULL,
[WorkflowGuid] [uniqueidentifier] NULL,
[UpdatedUser] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_Client_Instances] ADD CONSTRAINT [PK_Workflow_Client_Instances] PRIMARY KEY CLUSTERED ([WorkFlowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_Client_Instances] ADD CONSTRAINT [fk_Workflow_templateID] FOREIGN KEY ([TemplateId]) REFERENCES [dbo].[Workflow_Client_Templates] ([TemplateId])
GO
GRANT DELETE ON  [dbo].[Workflow_Client_Instances] TO [public]
GO
GRANT INSERT ON  [dbo].[Workflow_Client_Instances] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Workflow_Client_Instances] TO [public]
GO
GRANT SELECT ON  [dbo].[Workflow_Client_Instances] TO [public]
GO
GRANT UPDATE ON  [dbo].[Workflow_Client_Instances] TO [public]
GO
