CREATE TABLE [dbo].[Workflow_ActivityOutputs]
(
[Activity_ID] [int] NOT NULL,
[Activity_Field_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_ActivityOutputs] ADD CONSTRAINT [PK__Workflow__6ACA3FEE53AED68A] PRIMARY KEY CLUSTERED ([Activity_Field_Name], [Activity_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_ActivityOutputs] ADD CONSTRAINT [FK__Workflow___Activ__03464E7F] FOREIGN KEY ([Activity_ID]) REFERENCES [dbo].[Workflow_Activity] ([Activity_ID])
GO
GRANT DELETE ON  [dbo].[Workflow_ActivityOutputs] TO [public]
GO
GRANT INSERT ON  [dbo].[Workflow_ActivityOutputs] TO [public]
GO
GRANT SELECT ON  [dbo].[Workflow_ActivityOutputs] TO [public]
GO
GRANT UPDATE ON  [dbo].[Workflow_ActivityOutputs] TO [public]
GO
