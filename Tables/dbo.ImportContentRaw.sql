CREATE TABLE [dbo].[ImportContentRaw]
(
[ImportContentId] [int] NOT NULL,
[RawData] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportContentRaw] ADD CONSTRAINT [PK_ImportContentRaw] PRIMARY KEY CLUSTERED ([ImportContentId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportContentRaw] ADD CONSTRAINT [FK_ImportContentRaw_ImportContentId] FOREIGN KEY ([ImportContentId]) REFERENCES [dbo].[ImportContent] ([ImportContentId])
GO
GRANT DELETE ON  [dbo].[ImportContentRaw] TO [public]
GO
GRANT INSERT ON  [dbo].[ImportContentRaw] TO [public]
GO
GRANT SELECT ON  [dbo].[ImportContentRaw] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImportContentRaw] TO [public]
GO
