CREATE TABLE [dbo].[Workflow_ActivityGlobalOptions]
(
[Activity_ID] [int] NOT NULL,
[Activity_Field_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Activity_Value] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_ActivityGlobalOptions] ADD CONSTRAINT [PK__Workflow__6BAAC700C5154CF7] PRIMARY KEY CLUSTERED ([Activity_ID], [Activity_Field_Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_ActivityGlobalOptions] ADD CONSTRAINT [FK__Workflow___Activ__595014B3] FOREIGN KEY ([Activity_ID]) REFERENCES [dbo].[Workflow_Activity] ([Activity_ID])
GO
GRANT DELETE ON  [dbo].[Workflow_ActivityGlobalOptions] TO [public]
GO
GRANT INSERT ON  [dbo].[Workflow_ActivityGlobalOptions] TO [public]
GO
GRANT SELECT ON  [dbo].[Workflow_ActivityGlobalOptions] TO [public]
GO
GRANT UPDATE ON  [dbo].[Workflow_ActivityGlobalOptions] TO [public]
GO
