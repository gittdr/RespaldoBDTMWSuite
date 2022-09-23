CREATE TABLE [dbo].[Workflow_ActivityRequiredFields]
(
[Activity_ID] [int] NOT NULL,
[Activity_Field_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Activity_Field_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Workflow___Activ__1564FEBA] DEFAULT ('String'),
[Activity_Default_Test_Value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Workflow___Activ__165922F3] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_ActivityRequiredFields] ADD CONSTRAINT [PK__Workflow__6ACA3FEEEE628073] PRIMARY KEY CLUSTERED ([Activity_Field_Name], [Activity_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_ActivityRequiredFields] ADD CONSTRAINT [FK__Workflow___Activ__557F83CF] FOREIGN KEY ([Activity_ID]) REFERENCES [dbo].[Workflow_Activity] ([Activity_ID])
GO
ALTER TABLE [dbo].[Workflow_ActivityRequiredFields] ADD CONSTRAINT [FK__Workflow___Activ__548B5F96] FOREIGN KEY ([Activity_Field_Name]) REFERENCES [dbo].[Workflow_Fields] ([Workflow_Field_Name])
GO
GRANT DELETE ON  [dbo].[Workflow_ActivityRequiredFields] TO [public]
GO
GRANT INSERT ON  [dbo].[Workflow_ActivityRequiredFields] TO [public]
GO
GRANT SELECT ON  [dbo].[Workflow_ActivityRequiredFields] TO [public]
GO
GRANT UPDATE ON  [dbo].[Workflow_ActivityRequiredFields] TO [public]
GO
