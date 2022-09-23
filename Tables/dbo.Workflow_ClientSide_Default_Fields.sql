CREATE TABLE [dbo].[Workflow_ClientSide_Default_Fields]
(
[Type_ID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Workflow_Field_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_ClientSide_Default_Fields] ADD CONSTRAINT [PK__Workflow__76E51A13672B5374] PRIMARY KEY CLUSTERED ([Type_ID], [Workflow_Field_Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_ClientSide_Default_Fields] ADD CONSTRAINT [FK__Workflow___Type___7AB1087E] FOREIGN KEY ([Type_ID]) REFERENCES [dbo].[Workflow_Types] ([Type_ID])
GO
