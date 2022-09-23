CREATE TABLE [dbo].[Workflow_Query]
(
[WorkFlow_Query_ID] [int] NOT NULL IDENTITY(1, 1),
[WorkFlow_Template_id] [int] NOT NULL,
[Workflow_Query_Text] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Workflow___Activ__6E4B3199] DEFAULT ('N'),
[KeyField] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UseKey] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Workflow___UseKe__6F3F55D2] DEFAULT ('Y')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_Query] ADD CONSTRAINT [UQ__Workflow__F8BA3034BA4CD58F] UNIQUE NONCLUSTERED ([WorkFlow_Template_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_Query] ADD CONSTRAINT [FK__Workflow___WorkF__70337A0B] FOREIGN KEY ([WorkFlow_Template_id]) REFERENCES [dbo].[WorkFlow_Template] ([Workflow_Template_ID])
GO
