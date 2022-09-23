CREATE TABLE [dbo].[TMSShipmentStopReferenceNumber]
(
[ShipStopRefNumId] [int] NOT NULL IDENTITY(1, 1),
[ShipId] [int] NOT NULL,
[ShipStopId] [int] NOT NULL,
[Sequence] [int] NOT NULL,
[Type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSShipmentStopReferenceNumber] ADD CONSTRAINT [PK_TMSShipmentStopReferenceNumber] PRIMARY KEY CLUSTERED ([ShipStopRefNumId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_TTMSShipmentStopReferenceNumber_ShipId] ON [dbo].[TMSShipmentStopReferenceNumber] ([ShipId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSShipmentStopReferenceNumber] ADD CONSTRAINT [FK_MSShipmentStopReferenceNumber_ShipId] FOREIGN KEY ([ShipId]) REFERENCES [dbo].[TMSShipment] ([ShipId])
GO
ALTER TABLE [dbo].[TMSShipmentStopReferenceNumber] ADD CONSTRAINT [FK_MSShipmentStopReferenceNumber_ShipStopId] FOREIGN KEY ([ShipStopId]) REFERENCES [dbo].[TMSShipmentStops] ([ShipStopId])
GO
GRANT DELETE ON  [dbo].[TMSShipmentStopReferenceNumber] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSShipmentStopReferenceNumber] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSShipmentStopReferenceNumber] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSShipmentStopReferenceNumber] TO [public]
GO
