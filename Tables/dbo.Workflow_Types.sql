CREATE TABLE [dbo].[Workflow_Types]
(
[Type_ID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Type_Definition] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Is_Template_Type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Workflow___Is_Te__4360D394] DEFAULT ('N'),
[Is_Client_Type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Workflow___Is_Cl__174D472C] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_Types] ADD CONSTRAINT [PK__Workflow__FE90DDFEE4FC4D06] PRIMARY KEY CLUSTERED ([Type_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Workflow_Types] TO [public]
GO
GRANT INSERT ON  [dbo].[Workflow_Types] TO [public]
GO
GRANT SELECT ON  [dbo].[Workflow_Types] TO [public]
GO
GRANT UPDATE ON  [dbo].[Workflow_Types] TO [public]
GO
