CREATE TABLE [dbo].[ImportRowContentLinkFreight]
(
[ImportRowContentLinkFreightId] [int] NOT NULL IDENTITY(1, 1),
[ImportRowContentId] [int] NOT NULL,
[fgt_number] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportRowContentLinkFreight] ADD CONSTRAINT [PK_ImportRowContentLinkFreight] PRIMARY KEY CLUSTERED ([ImportRowContentLinkFreightId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_ImportRowContentLinkFreight_fgt_number] ON [dbo].[ImportRowContentLinkFreight] ([fgt_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_ImportRowContentLinkFreight_ImportRowContentId] ON [dbo].[ImportRowContentLinkFreight] ([ImportRowContentId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportRowContentLinkFreight] ADD CONSTRAINT [FK_ImportRowContentLinkFreight_ImportRowContentId] FOREIGN KEY ([ImportRowContentId]) REFERENCES [dbo].[ImportRowContent] ([ImportRowContentId])
GO
GRANT DELETE ON  [dbo].[ImportRowContentLinkFreight] TO [public]
GO
GRANT INSERT ON  [dbo].[ImportRowContentLinkFreight] TO [public]
GO
GRANT SELECT ON  [dbo].[ImportRowContentLinkFreight] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImportRowContentLinkFreight] TO [public]
GO
