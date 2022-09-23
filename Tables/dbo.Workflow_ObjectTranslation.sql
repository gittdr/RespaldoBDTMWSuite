CREATE TABLE [dbo].[Workflow_ObjectTranslation]
(
[Workflow_Translation_ID] [int] NOT NULL IDENTITY(1, 1),
[TMW_Object] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TMW_ObjectVersion] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[User_Object] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[User_ObectVersion] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_ObjectTranslation] ADD CONSTRAINT [PK__Workflow__DCBCBD29AE2876B4] PRIMARY KEY CLUSTERED ([Workflow_Translation_ID]) ON [PRIMARY]
GO
