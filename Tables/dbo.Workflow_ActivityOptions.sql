CREATE TABLE [dbo].[Workflow_ActivityOptions]
(
[WorkFlow_Sequence] [int] NOT NULL,
[Activity_ID] [int] NULL,
[Activity_Option_Field_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Activity_Option_Type] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Activity_Option_Value] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Workflow_ActivityOptions] TO [public]
GO
GRANT INSERT ON  [dbo].[Workflow_ActivityOptions] TO [public]
GO
GRANT SELECT ON  [dbo].[Workflow_ActivityOptions] TO [public]
GO
GRANT UPDATE ON  [dbo].[Workflow_ActivityOptions] TO [public]
GO
