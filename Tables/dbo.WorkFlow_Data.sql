CREATE TABLE [dbo].[WorkFlow_Data]
(
[WorkFlow_ID] [int] NOT NULL,
[Workflow_Field_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Workflow_Field_Data] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkFlow_Data] ADD CONSTRAINT [PK__WorkFlow__A262E10E391FFF0B] PRIMARY KEY CLUSTERED ([WorkFlow_ID], [Workflow_Field_Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkFlow_Data] ADD CONSTRAINT [FK__WorkFlow___WorkF__74F82F28] FOREIGN KEY ([WorkFlow_ID]) REFERENCES [dbo].[Workflow] ([WorkFlow_ID])
GO
