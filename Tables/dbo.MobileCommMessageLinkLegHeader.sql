CREATE TABLE [dbo].[MobileCommMessageLinkLegHeader]
(
[LinkLegHeaderId] [bigint] NOT NULL IDENTITY(1, 1),
[MessageId] [bigint] NOT NULL,
[lgh_number] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageLinkLegHeader] ADD CONSTRAINT [PK_MobileCommMessageLinkLegHeader] PRIMARY KEY CLUSTERED ([LinkLegHeaderId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_MobileCommMessageLinkLegHeader_trc_Number_MessageId] ON [dbo].[MobileCommMessageLinkLegHeader] ([lgh_number], [MessageId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_MobileCommMessageLinkLegHeader_MessageId_LegNumber] ON [dbo].[MobileCommMessageLinkLegHeader] ([MessageId]) INCLUDE ([lgh_number]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageLinkLegHeader] ADD CONSTRAINT [FK_MobileCommMessageLinkLegHeader_legheader_lgh_number] FOREIGN KEY ([lgh_number]) REFERENCES [dbo].[legheader] ([lgh_number]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MobileCommMessageLinkLegHeader] ADD CONSTRAINT [FK_MobileCommMessageLinkLegHeader_MobileCommMessageInstance_MessageId] FOREIGN KEY ([MessageId]) REFERENCES [dbo].[MobileCommMessage] ([MessageId]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[MobileCommMessageLinkLegHeader] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommMessageLinkLegHeader] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommMessageLinkLegHeader] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommMessageLinkLegHeader] TO [public]
GO
