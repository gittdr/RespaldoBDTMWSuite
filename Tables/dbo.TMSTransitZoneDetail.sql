CREATE TABLE [dbo].[TMSTransitZoneDetail]
(
[DetailID] [int] NOT NULL IDENTITY(1, 1),
[ZoneKey] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TransitID] [int] NOT NULL,
[GeographyType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSTransitZoneDetail] ADD CONSTRAINT [PK_TMSTransitZoneDetail] PRIMARY KEY CLUSTERED ([DetailID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_TMSTransitZoneDetail_ZoneKey_TransitID] ON [dbo].[TMSTransitZoneDetail] ([ZoneKey], [TransitID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSTransitZoneDetail] ADD CONSTRAINT [FK_TMSTransitZoneDetail_TMSGeographyType] FOREIGN KEY ([GeographyType]) REFERENCES [dbo].[TMSGeographyType] ([GeographyType])
GO
ALTER TABLE [dbo].[TMSTransitZoneDetail] ADD CONSTRAINT [FK_TMSTransitZoneDetail_TMSTransit] FOREIGN KEY ([TransitID]) REFERENCES [dbo].[TMSTransit] ([TransitID])
GO
ALTER TABLE [dbo].[TMSTransitZoneDetail] ADD CONSTRAINT [FK_TMSTransitZoneDetail_TMSTransitZone] FOREIGN KEY ([ZoneKey], [TransitID]) REFERENCES [dbo].[TMSTransitZone] ([ZoneKey], [TransitID])
GO
GRANT DELETE ON  [dbo].[TMSTransitZoneDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSTransitZoneDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSTransitZoneDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSTransitZoneDetail] TO [public]
GO
