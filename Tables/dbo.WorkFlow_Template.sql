CREATE TABLE [dbo].[WorkFlow_Template]
(
[Workflow_Template_ID] [int] NOT NULL IDENTITY(1, 1),
[Workflow_Template_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Workflow_Template_Type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Workflow_Template_Creation_date] [datetime] NULL,
[Workflow_Template_modification_date] [datetime] NULL,
[Is_ClientSide] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__WorkFlow___Is_Cl__463D403F] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkFlow_Template] ADD CONSTRAINT [PK__WorkFlow__778654FDC83D9352] PRIMARY KEY CLUSTERED ([Workflow_Template_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkFlow_Template] ADD CONSTRAINT [FK__WorkFlow___Workf__47316478] FOREIGN KEY ([Workflow_Template_Type]) REFERENCES [dbo].[Workflow_Types] ([Type_ID])
GO
GRANT DELETE ON  [dbo].[WorkFlow_Template] TO [public]
GO
GRANT INSERT ON  [dbo].[WorkFlow_Template] TO [public]
GO
GRANT SELECT ON  [dbo].[WorkFlow_Template] TO [public]
GO
GRANT UPDATE ON  [dbo].[WorkFlow_Template] TO [public]
GO
