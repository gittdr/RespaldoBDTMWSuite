CREATE TABLE [dbo].[tmwsuite_workflow_requiredfields]
(
[workflow_id] [int] NOT NULL,
[requiredfieldname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[requiredfieldvalue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tmwsuite_workflow_requiredfields] ADD CONSTRAINT [pk_tmwsuite_workflow_requiredfields] PRIMARY KEY CLUSTERED ([workflow_id], [requiredfieldname]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tmwsuite_workflow_requiredfields] TO [public]
GO
GRANT INSERT ON  [dbo].[tmwsuite_workflow_requiredfields] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tmwsuite_workflow_requiredfields] TO [public]
GO
GRANT SELECT ON  [dbo].[tmwsuite_workflow_requiredfields] TO [public]
GO
GRANT UPDATE ON  [dbo].[tmwsuite_workflow_requiredfields] TO [public]
GO
