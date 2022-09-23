CREATE TABLE [dbo].[TMSShipmentStops]
(
[ShipStopId] [int] NOT NULL IDENTITY(1, 1),
[ShipId] [int] NOT NULL,
[LocationId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationAltId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationCityCode] [int] NULL,
[LocationCityState] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationLat] [decimal] (12, 5) NULL,
[LocationLong] [decimal] (12, 5) NULL,
[WindowDateEarliest] [datetime] NOT NULL,
[WindowDateLatest] [datetime] NOT NULL,
[PlannedArrival] [datetime] NOT NULL,
[PlannedDeparture] [datetime] NOT NULL,
[ActualArrival] [datetime] NULL,
[ActualDeparture] [datetime] NULL,
[Distance] [decimal] (12, 5) NULL,
[TravelTime] [decimal] (12, 5) NULL,
[Sequence] [int] NOT NULL,
[EstimatedArrival] [datetime] NULL,
[EstimatedDeparture] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSShipmentStops] ADD CONSTRAINT [PK_TMSShipmentStops] PRIMARY KEY CLUSTERED ([ShipStopId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSShipmentStops] ADD CONSTRAINT [FK_TMSShipmentStops_TMSShipment] FOREIGN KEY ([ShipId]) REFERENCES [dbo].[TMSShipment] ([ShipId])
GO
GRANT DELETE ON  [dbo].[TMSShipmentStops] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSShipmentStops] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSShipmentStops] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSShipmentStops] TO [public]
GO
