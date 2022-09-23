CREATE TABLE [dbo].[TMSShipmentStopDetail]
(
[DetailId] [int] NOT NULL IDENTITY(1, 1),
[ShipStopId] [int] NOT NULL,
[ShipId] [int] NOT NULL,
[OrderId] [int] NULL,
[StopId] [int] NULL,
[EventType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mov_number] [int] NULL,
[ord_hdrnumber] [int] NULL,
[lgh_number] [int] NULL,
[stp_number] [int] NULL,
[fgt_number] [int] NULL,
[XDockId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSShipmentStopDetail] ADD CONSTRAINT [PK_TMSShipmentStopDetail] PRIMARY KEY CLUSTERED ([DetailId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DX_TMSShipmentStopDetail_mov_number] ON [dbo].[TMSShipmentStopDetail] ([mov_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DX_TMSShipmentStopDetail_ord_hdrnumber] ON [dbo].[TMSShipmentStopDetail] ([ord_hdrnumber]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSShipmentStopDetail] ADD CONSTRAINT [FK_TMSOrderXDock_TMSShipmentStopDetail] FOREIGN KEY ([XDockId]) REFERENCES [dbo].[TMSOrderXDock] ([XDockId])
GO
ALTER TABLE [dbo].[TMSShipmentStopDetail] ADD CONSTRAINT [FK_TMSShipmentStopDetail_TMSEvents] FOREIGN KEY ([EventType]) REFERENCES [dbo].[TMSEvents] ([EventType])
GO
ALTER TABLE [dbo].[TMSShipmentStopDetail] ADD CONSTRAINT [FK_TMSShipmentStopDetail_TMSOrder] FOREIGN KEY ([OrderId]) REFERENCES [dbo].[TMSOrder] ([OrderId])
GO
ALTER TABLE [dbo].[TMSShipmentStopDetail] ADD CONSTRAINT [FK_TMSShipmentStopDetail_TMSShipment] FOREIGN KEY ([ShipId]) REFERENCES [dbo].[TMSShipment] ([ShipId])
GO
ALTER TABLE [dbo].[TMSShipmentStopDetail] ADD CONSTRAINT [FK_TMSShipmentStopDetail_TMSShipmentStops] FOREIGN KEY ([ShipStopId]) REFERENCES [dbo].[TMSShipmentStops] ([ShipStopId])
GO
ALTER TABLE [dbo].[TMSShipmentStopDetail] ADD CONSTRAINT [FK_TMSShipmentStopDetail_TMSStops] FOREIGN KEY ([StopId]) REFERENCES [dbo].[TMSStops] ([StopId])
GO
GRANT DELETE ON  [dbo].[TMSShipmentStopDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSShipmentStopDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSShipmentStopDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSShipmentStopDetail] TO [public]
GO
