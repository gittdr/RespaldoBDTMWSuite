CREATE TABLE [dbo].[ImportRowContentLinkOrder]
(
[ImportRowContentLinkOrderId] [int] NOT NULL IDENTITY(1, 1),
[ImportRowContentId] [int] NOT NULL,
[ord_hdrnumber] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportRowContentLinkOrder] ADD CONSTRAINT [PK_ImportRowContentLinkOrder] PRIMARY KEY CLUSTERED ([ImportRowContentLinkOrderId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_ImportRowContentLinkOrder_ImportRowContentId] ON [dbo].[ImportRowContentLinkOrder] ([ImportRowContentId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_ImportRowContentLinkOrder_ord_hdrnumber] ON [dbo].[ImportRowContentLinkOrder] ([ord_hdrnumber]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportRowContentLinkOrder] ADD CONSTRAINT [FK_ImportRowContentLinkOrder_ImportRowContentId] FOREIGN KEY ([ImportRowContentId]) REFERENCES [dbo].[ImportRowContent] ([ImportRowContentId])
GO
GRANT DELETE ON  [dbo].[ImportRowContentLinkOrder] TO [public]
GO
GRANT INSERT ON  [dbo].[ImportRowContentLinkOrder] TO [public]
GO
GRANT SELECT ON  [dbo].[ImportRowContentLinkOrder] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImportRowContentLinkOrder] TO [public]
GO
