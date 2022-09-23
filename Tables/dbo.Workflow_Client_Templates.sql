CREATE TABLE [dbo].[Workflow_Client_Templates]
(
[TemplateId] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Workflow___Statu__3D150001] DEFAULT ('Inactive'),
[SimpleType] [bit] NOT NULL CONSTRAINT [DF__Workflow___Simpl__3E09243A] DEFAULT ((0)),
[Content] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreationDate] [datetime] NULL,
[EnableLogging] [bit] NOT NULL CONSTRAINT [DF__Workflow___Enabl__3EFD4873] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_Client_Templates] ADD CONSTRAINT [PK_Workflow_Client_Templates] PRIMARY KEY CLUSTERED ([TemplateId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Workflow_Client_Templates] TO [public]
GO
GRANT INSERT ON  [dbo].[Workflow_Client_Templates] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Workflow_Client_Templates] TO [public]
GO
GRANT SELECT ON  [dbo].[Workflow_Client_Templates] TO [public]
GO
GRANT UPDATE ON  [dbo].[Workflow_Client_Templates] TO [public]
GO
