CREATE TABLE [dbo].[ImportContent]
(
[ImportContentId] [int] NOT NULL IDENTITY(1, 1),
[ImportDefinitionId] [int] NOT NULL,
[FileName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileDate] [datetime] NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[CreatedBy] [int] NOT NULL CONSTRAINT [DF_ImportContent_CreatedBy] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportContent] ADD CONSTRAINT [PK_ImportContent] PRIMARY KEY CLUSTERED ([ImportContentId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportContent] ADD CONSTRAINT [FK_ImportContent_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[TMWUsers] ([UserId])
GO
ALTER TABLE [dbo].[ImportContent] ADD CONSTRAINT [FK_ImportContent_ImportDefinitionId] FOREIGN KEY ([ImportDefinitionId]) REFERENCES [dbo].[ImportDefinition] ([ImportDefinitionId])
GO
GRANT DELETE ON  [dbo].[ImportContent] TO [public]
GO
GRANT INSERT ON  [dbo].[ImportContent] TO [public]
GO
GRANT SELECT ON  [dbo].[ImportContent] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImportContent] TO [public]
GO
