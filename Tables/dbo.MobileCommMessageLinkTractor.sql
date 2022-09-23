CREATE TABLE [dbo].[MobileCommMessageLinkTractor]
(
[LinkTractorId] [bigint] NOT NULL IDENTITY(1, 1),
[MessageId] [bigint] NOT NULL,
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageLinkTractor] ADD CONSTRAINT [PK_MobileCommMessageLinkTractor] PRIMARY KEY CLUSTERED ([LinkTractorId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_MobileCommMessageLinkTractor_MessageId_trc_number] ON [dbo].[MobileCommMessageLinkTractor] ([MessageId], [trc_number]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_MobileCommMessageLinkTractor_trc_Number_MessageId] ON [dbo].[MobileCommMessageLinkTractor] ([trc_number], [MessageId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageLinkTractor] ADD CONSTRAINT [FK_MobileCommMessageLinkTractor_MobileCommMessageInstance_MessageId] FOREIGN KEY ([MessageId]) REFERENCES [dbo].[MobileCommMessage] ([MessageId]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MobileCommMessageLinkTractor] ADD CONSTRAINT [FK_MobileCommMessageLinkTractor_TractorProfile_Trc_number] FOREIGN KEY ([trc_number]) REFERENCES [dbo].[tractorprofile] ([trc_number]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[MobileCommMessageLinkTractor] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommMessageLinkTractor] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommMessageLinkTractor] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommMessageLinkTractor] TO [public]
GO
