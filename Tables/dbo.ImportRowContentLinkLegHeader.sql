CREATE TABLE [dbo].[ImportRowContentLinkLegHeader]
(
[ImportRowContentLinkLegHeaderId] [int] NOT NULL IDENTITY(1, 1),
[ImportRowContentId] [int] NOT NULL,
[lgh_number] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportRowContentLinkLegHeader] ADD CONSTRAINT [PK_ImportRowContentLinkLegHeader] PRIMARY KEY CLUSTERED ([ImportRowContentLinkLegHeaderId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_ImportRowContentLinkLegHeader_ImportRowContentId] ON [dbo].[ImportRowContentLinkLegHeader] ([ImportRowContentId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_ImportRowContentLinkLegHeader_lgh_number] ON [dbo].[ImportRowContentLinkLegHeader] ([lgh_number]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportRowContentLinkLegHeader] ADD CONSTRAINT [FK_ImportRowContentLinkLegHeader_ImportRowContentId] FOREIGN KEY ([ImportRowContentId]) REFERENCES [dbo].[ImportRowContent] ([ImportRowContentId])
GO
GRANT DELETE ON  [dbo].[ImportRowContentLinkLegHeader] TO [public]
GO
GRANT INSERT ON  [dbo].[ImportRowContentLinkLegHeader] TO [public]
GO
GRANT SELECT ON  [dbo].[ImportRowContentLinkLegHeader] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImportRowContentLinkLegHeader] TO [public]
GO
