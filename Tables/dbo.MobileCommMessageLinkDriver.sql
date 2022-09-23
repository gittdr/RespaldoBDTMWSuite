CREATE TABLE [dbo].[MobileCommMessageLinkDriver]
(
[LinkDriverId] [bigint] NOT NULL IDENTITY(1, 1),
[MessageId] [bigint] NOT NULL,
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageLinkDriver] ADD CONSTRAINT [PK_MobileCommMessageLinkDriver] PRIMARY KEY CLUSTERED ([LinkDriverId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_MobileCommMessageLinkDriver_MessageId_mpp_id] ON [dbo].[MobileCommMessageLinkDriver] ([MessageId], [mpp_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_MobileCommMessageLinkDriver_mpp_id_MessageId] ON [dbo].[MobileCommMessageLinkDriver] ([mpp_id], [MessageId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageLinkDriver] ADD CONSTRAINT [FK_MobileCommMessageLinkDriver_manpowerprofile_mpp_id] FOREIGN KEY ([mpp_id]) REFERENCES [dbo].[manpowerprofile] ([mpp_id]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MobileCommMessageLinkDriver] ADD CONSTRAINT [FK_MobileCommMessageLinkDriver_MobileCommMessageInstance_MessageId] FOREIGN KEY ([MessageId]) REFERENCES [dbo].[MobileCommMessage] ([MessageId]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[MobileCommMessageLinkDriver] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommMessageLinkDriver] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommMessageLinkDriver] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommMessageLinkDriver] TO [public]
GO
