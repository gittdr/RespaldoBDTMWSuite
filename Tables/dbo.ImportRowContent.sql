CREATE TABLE [dbo].[ImportRowContent]
(
[ImportRowContentId] [int] NOT NULL IDENTITY(1, 1),
[ImportContentId] [int] NOT NULL,
[IsDefinitionValid] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportRowContent] ADD CONSTRAINT [PK_ImportRowContent] PRIMARY KEY CLUSTERED ([ImportRowContentId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_ImportRowContent_ImportContentId] ON [dbo].[ImportRowContent] ([ImportContentId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportRowContent] ADD CONSTRAINT [FK_ImportRowContent_ImportContentId] FOREIGN KEY ([ImportContentId]) REFERENCES [dbo].[ImportContent] ([ImportContentId])
GO
GRANT DELETE ON  [dbo].[ImportRowContent] TO [public]
GO
GRANT INSERT ON  [dbo].[ImportRowContent] TO [public]
GO
GRANT SELECT ON  [dbo].[ImportRowContent] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImportRowContent] TO [public]
GO
