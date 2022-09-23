CREATE TABLE [dbo].[TMSTransitMatrix]
(
[MatrixID] [int] NOT NULL IDENTITY(1, 1),
[TransitID] [int] NOT NULL,
[FromZoneKey] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToZoneKey] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ServiceDays] [decimal] (10, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSTransitMatrix] ADD CONSTRAINT [PK_TMSTransitMatrix] PRIMARY KEY CLUSTERED ([MatrixID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSTransitMatrix] ADD CONSTRAINT [FK_TMSTransitMatrix_TMSTransit] FOREIGN KEY ([TransitID]) REFERENCES [dbo].[TMSTransit] ([TransitID])
GO
ALTER TABLE [dbo].[TMSTransitMatrix] ADD CONSTRAINT [FK_TMSTransitMatrix_TMSTransitZoneFrom] FOREIGN KEY ([FromZoneKey], [TransitID]) REFERENCES [dbo].[TMSTransitZone] ([ZoneKey], [TransitID])
GO
ALTER TABLE [dbo].[TMSTransitMatrix] ADD CONSTRAINT [FK_TMSTransitMatrix_TMSTransitZoneTo] FOREIGN KEY ([ToZoneKey], [TransitID]) REFERENCES [dbo].[TMSTransitZone] ([ZoneKey], [TransitID])
GO
GRANT DELETE ON  [dbo].[TMSTransitMatrix] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSTransitMatrix] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSTransitMatrix] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSTransitMatrix] TO [public]
GO
