CREATE TABLE [dbo].[Workflow_Client_Mapping]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Object] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SaveType] [int] NOT NULL,
[Workflow_ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_Client_Mapping] ADD CONSTRAINT [PK__Workflow__3214EC270A802A4C] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_Client_Mapping] ADD CONSTRAINT [fk_Workflow_mapping] FOREIGN KEY ([Workflow_ID]) REFERENCES [dbo].[Workflow_Client_Templates] ([TemplateId])
GO
GRANT DELETE ON  [dbo].[Workflow_Client_Mapping] TO [public]
GO
GRANT INSERT ON  [dbo].[Workflow_Client_Mapping] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Workflow_Client_Mapping] TO [public]
GO
GRANT SELECT ON  [dbo].[Workflow_Client_Mapping] TO [public]
GO
GRANT UPDATE ON  [dbo].[Workflow_Client_Mapping] TO [public]
GO
