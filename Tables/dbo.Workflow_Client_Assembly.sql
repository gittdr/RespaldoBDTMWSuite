CREATE TABLE [dbo].[Workflow_Client_Assembly]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Name] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Assembly] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateModified] [datetime] NOT NULL,
[Assembly_Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Workflow_Client_Assembly] TO [public]
GO
GRANT INSERT ON  [dbo].[Workflow_Client_Assembly] TO [public]
GO
GRANT SELECT ON  [dbo].[Workflow_Client_Assembly] TO [public]
GO
GRANT UPDATE ON  [dbo].[Workflow_Client_Assembly] TO [public]
GO
