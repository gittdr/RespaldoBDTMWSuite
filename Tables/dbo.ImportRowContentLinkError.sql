CREATE TABLE [dbo].[ImportRowContentLinkError]
(
[ImportRowContentLinkErrorId] [int] NOT NULL IDENTITY(1, 1),
[ImportRowContentId] [int] NOT NULL,
[ImportErrorId] [int] NOT NULL,
[ImportColumnId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportRowContentLinkError] ADD CONSTRAINT [PK_ImportRowContentLinkError] PRIMARY KEY CLUSTERED ([ImportRowContentLinkErrorId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_ImportRowContentLinkError_ImportRowContentId] ON [dbo].[ImportRowContentLinkError] ([ImportRowContentId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportRowContentLinkError] ADD CONSTRAINT [FK_ImportRowContentLinkError_ImportColumnId] FOREIGN KEY ([ImportColumnId]) REFERENCES [dbo].[ImportColumn] ([ImportColumnId])
GO
ALTER TABLE [dbo].[ImportRowContentLinkError] ADD CONSTRAINT [FK_ImportRowContentLinkError_ImportErrorId] FOREIGN KEY ([ImportErrorId]) REFERENCES [dbo].[ImportError] ([ImportErrorId])
GO
ALTER TABLE [dbo].[ImportRowContentLinkError] ADD CONSTRAINT [FK_ImportRowContentLinkError_ImportRowContentId] FOREIGN KEY ([ImportRowContentId]) REFERENCES [dbo].[ImportRowContent] ([ImportRowContentId])
GO
GRANT DELETE ON  [dbo].[ImportRowContentLinkError] TO [public]
GO
GRANT INSERT ON  [dbo].[ImportRowContentLinkError] TO [public]
GO
GRANT SELECT ON  [dbo].[ImportRowContentLinkError] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImportRowContentLinkError] TO [public]
GO
