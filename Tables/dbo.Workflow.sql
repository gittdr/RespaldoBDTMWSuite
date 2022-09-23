CREATE TABLE [dbo].[Workflow]
(
[WorkFlow_ID] [int] NOT NULL IDENTITY(1, 1),
[Workflow_Template_ID] [int] NULL,
[Workflow_Start_Time] [datetime] NULL,
[Workflow_End_Time] [datetime] NULL,
[WorkFlow_Current_Sequence_ID] [int] NOT NULL,
[WorkFlow_NextProcessTime] [datetime] NULL,
[Workflow_OutCome] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Workflow_StartValue] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Workflow_instance] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Workflow_ActualStartTime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow] ADD CONSTRAINT [PK__Workflow__2A1726E3B212BCA5] PRIMARY KEY CLUSTERED ([WorkFlow_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [workflow_nextprocesstime_outcome] ON [dbo].[Workflow] ([WorkFlow_NextProcessTime], [Workflow_OutCome]) INCLUDE ([WorkFlow_ID], [Workflow_Template_ID], [Workflow_Start_Time], [Workflow_End_Time], [WorkFlow_Current_Sequence_ID], [Workflow_StartValue]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [workflow_templateid_outcome_instance] ON [dbo].[Workflow] ([Workflow_Template_ID], [Workflow_OutCome], [Workflow_instance]) ON [PRIMARY]
GO
