CREATE TABLE [dbo].[ImportRowContentLinkStop]
(
[ImportRowContentLinkStopId] [int] NOT NULL IDENTITY(1, 1),
[ImportRowContentId] [int] NOT NULL,
[stp_number] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportRowContentLinkStop] ADD CONSTRAINT [PK_ImportRowContentLinkStop] PRIMARY KEY CLUSTERED ([ImportRowContentLinkStopId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_ImportRowContentLinkStop_ImportRowContentId] ON [dbo].[ImportRowContentLinkStop] ([ImportRowContentId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_ImportRowContentLinkStop_stp_number] ON [dbo].[ImportRowContentLinkStop] ([stp_number]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportRowContentLinkStop] ADD CONSTRAINT [FK_ImportRowContentLinkStop_ImportRowContentId] FOREIGN KEY ([ImportRowContentId]) REFERENCES [dbo].[ImportRowContent] ([ImportRowContentId])
GO
GRANT DELETE ON  [dbo].[ImportRowContentLinkStop] TO [public]
GO
GRANT INSERT ON  [dbo].[ImportRowContentLinkStop] TO [public]
GO
GRANT SELECT ON  [dbo].[ImportRowContentLinkStop] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImportRowContentLinkStop] TO [public]
GO
