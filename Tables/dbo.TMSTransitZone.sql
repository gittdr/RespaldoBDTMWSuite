CREATE TABLE [dbo].[TMSTransitZone]
(
[ZoneKey] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TransitID] [int] NOT NULL,
[ServiceType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSTransitZone] ADD CONSTRAINT [PK_TMSTransitZoneTransitId] PRIMARY KEY CLUSTERED ([ZoneKey], [TransitID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSTransitZone] ADD CONSTRAINT [FK_TMSTransitZone_TMSTransit] FOREIGN KEY ([TransitID]) REFERENCES [dbo].[TMSTransit] ([TransitID])
GO
GRANT DELETE ON  [dbo].[TMSTransitZone] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSTransitZone] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSTransitZone] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSTransitZone] TO [public]
GO
