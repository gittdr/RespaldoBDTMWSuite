CREATE TABLE [dbo].[ImportColumnContent]
(
[ImportColumnContentId] [int] NOT NULL IDENTITY(1, 1),
[ImportRowContentId] [int] NOT NULL,
[ImportColumnId] [int] NOT NULL,
[Data] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportColumnContent] ADD CONSTRAINT [PK_ImportColumnContent] PRIMARY KEY CLUSTERED ([ImportColumnContentId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ImportColumnContent_ImportColumnId_ImportRowContentId] ON [dbo].[ImportColumnContent] ([ImportColumnId], [ImportRowContentId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ImportColumnContent_ImportRowContentId_ImportColumnId] ON [dbo].[ImportColumnContent] ([ImportRowContentId], [ImportColumnId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportColumnContent] ADD CONSTRAINT [FK_ImportColumnContent_ImportColumnId] FOREIGN KEY ([ImportColumnId]) REFERENCES [dbo].[ImportColumn] ([ImportColumnId])
GO
ALTER TABLE [dbo].[ImportColumnContent] ADD CONSTRAINT [FK_ImportColumnContent_ImportRowContentId] FOREIGN KEY ([ImportRowContentId]) REFERENCES [dbo].[ImportRowContent] ([ImportRowContentId])
GO
GRANT DELETE ON  [dbo].[ImportColumnContent] TO [public]
GO
GRANT INSERT ON  [dbo].[ImportColumnContent] TO [public]
GO
GRANT SELECT ON  [dbo].[ImportColumnContent] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImportColumnContent] TO [public]
GO
