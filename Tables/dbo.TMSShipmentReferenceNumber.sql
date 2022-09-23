CREATE TABLE [dbo].[TMSShipmentReferenceNumber]
(
[ShipRefNumId] [int] NOT NULL IDENTITY(1, 1),
[ShipId] [int] NOT NULL,
[Sequence] [int] NOT NULL,
[Type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSShipmentReferenceNumber] ADD CONSTRAINT [PK_ShipRefNumId] PRIMARY KEY CLUSTERED ([ShipRefNumId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_TMSShipmentReferenceNumber_ShipId] ON [dbo].[TMSShipmentReferenceNumber] ([ShipId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSShipmentReferenceNumber] ADD CONSTRAINT [FK_TMSShipmentReferenceNumber_ShipId] FOREIGN KEY ([ShipId]) REFERENCES [dbo].[TMSShipment] ([ShipId])
GO
GRANT DELETE ON  [dbo].[TMSShipmentReferenceNumber] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSShipmentReferenceNumber] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSShipmentReferenceNumber] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSShipmentReferenceNumber] TO [public]
GO
