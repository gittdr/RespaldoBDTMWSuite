CREATE TABLE [dbo].[Workflow_Fields]
(
[Workflow_Field_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_Fields] ADD CONSTRAINT [PK__Workflow__875C7ED9DE5ED72B] PRIMARY KEY CLUSTERED ([Workflow_Field_Name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Workflow_Fields] TO [public]
GO
GRANT INSERT ON  [dbo].[Workflow_Fields] TO [public]
GO
GRANT SELECT ON  [dbo].[Workflow_Fields] TO [public]
GO
GRANT UPDATE ON  [dbo].[Workflow_Fields] TO [public]
GO
