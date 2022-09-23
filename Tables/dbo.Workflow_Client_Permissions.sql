CREATE TABLE [dbo].[Workflow_Client_Permissions]
(
[Mapping_ID] [int] NOT NULL,
[PID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Type] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_Client_Permissions] ADD CONSTRAINT [PK__Workflow__5CFD2C5F7557EDA1] PRIMARY KEY CLUSTERED ([Mapping_ID], [PID], [Type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Workflow_Client_Permissions] TO [public]
GO
GRANT INSERT ON  [dbo].[Workflow_Client_Permissions] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Workflow_Client_Permissions] TO [public]
GO
GRANT SELECT ON  [dbo].[Workflow_Client_Permissions] TO [public]
GO
GRANT UPDATE ON  [dbo].[Workflow_Client_Permissions] TO [public]
GO
