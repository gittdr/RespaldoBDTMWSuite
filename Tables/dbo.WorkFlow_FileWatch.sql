CREATE TABLE [dbo].[WorkFlow_FileWatch]
(
[Workflow_FileName] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Workflow_DirectoryName] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkFlow_Template_id] [int] NOT NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__WorkFlow___Activ__5C2C815E] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkFlow_FileWatch] ADD CONSTRAINT [PK__WorkFlow__F8BA3035630676EC] PRIMARY KEY CLUSTERED ([WorkFlow_Template_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkFlow_FileWatch] ADD CONSTRAINT [FK__WorkFlow___WorkF__5D20A597] FOREIGN KEY ([WorkFlow_Template_id]) REFERENCES [dbo].[WorkFlow_Template] ([Workflow_Template_ID])
GO
