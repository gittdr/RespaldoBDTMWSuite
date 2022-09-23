CREATE TABLE [dbo].[Workflow_ClientSideOptions]
(
[Workflow_Template_ID] [int] NOT NULL,
[Workflow_Field_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_ClientSideOptions] ADD CONSTRAINT [PK__Workflow__FFF39310C4D60C77] PRIMARY KEY CLUSTERED ([Workflow_Template_ID], [Workflow_Field_Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_ClientSideOptions] ADD CONSTRAINT [FK__Workflow___Workf__77D49BD3] FOREIGN KEY ([Workflow_Template_ID]) REFERENCES [dbo].[WorkFlow_Template] ([Workflow_Template_ID])
GO
GRANT DELETE ON  [dbo].[Workflow_ClientSideOptions] TO [public]
GO
GRANT INSERT ON  [dbo].[Workflow_ClientSideOptions] TO [public]
GO
GRANT SELECT ON  [dbo].[Workflow_ClientSideOptions] TO [public]
GO
GRANT UPDATE ON  [dbo].[Workflow_ClientSideOptions] TO [public]
GO
