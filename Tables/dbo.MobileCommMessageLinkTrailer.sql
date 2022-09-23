CREATE TABLE [dbo].[MobileCommMessageLinkTrailer]
(
[LinkTrailerId] [bigint] NOT NULL IDENTITY(1, 1),
[MessageId] [bigint] NOT NULL,
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageLinkTrailer] ADD CONSTRAINT [PK_MobileCommMessageLinkTrailer] PRIMARY KEY CLUSTERED ([LinkTrailerId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_MobileCommMessageLinkTrailer_MessageId_TrailerId] ON [dbo].[MobileCommMessageLinkTrailer] ([MessageId]) INCLUDE ([trl_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_MobileCommMessageLinkTrailer_TrailerId_MessageId] ON [dbo].[MobileCommMessageLinkTrailer] ([trl_id]) INCLUDE ([MessageId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageLinkTrailer] ADD CONSTRAINT [FK_MobileCommMessageLinkTrailer_MobileCommMessageInstance_MessageId] FOREIGN KEY ([MessageId]) REFERENCES [dbo].[MobileCommMessage] ([MessageId]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MobileCommMessageLinkTrailer] ADD CONSTRAINT [FK_MobileCommMessageLinkTrailer_trailerprofile_trl_id] FOREIGN KEY ([trl_id]) REFERENCES [dbo].[trailerprofile] ([trl_id]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[MobileCommMessageLinkTrailer] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommMessageLinkTrailer] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommMessageLinkTrailer] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommMessageLinkTrailer] TO [public]
GO
