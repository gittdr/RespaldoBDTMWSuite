CREATE TABLE [dbo].[Workflow_ObjectTranslationFields]
(
[Workflow_TranslationFieldID] [int] NOT NULL IDENTITY(1, 1),
[Workflow_Translation_ID] [int] NULL,
[TMW_FieldName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[User_ObectFieldName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Default_Value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_ObjectTranslationFields] ADD CONSTRAINT [PK__Workflow__A9F4B3870384E68A] PRIMARY KEY CLUSTERED ([Workflow_TranslationFieldID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_ObjectTranslationFields] ADD CONSTRAINT [FK__Workflow___Defau__080B039C] FOREIGN KEY ([Workflow_Translation_ID]) REFERENCES [dbo].[Workflow_ObjectTranslation] ([Workflow_Translation_ID])
GO
