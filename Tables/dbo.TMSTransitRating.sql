CREATE TABLE [dbo].[TMSTransitRating]
(
[RateId] [bigint] NOT NULL IDENTITY(1, 1),
[TransitID] [int] NOT NULL,
[OrderId] [int] NULL,
[ShipId] [int] NULL,
[IsSellRate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UpdateDate] [datetime] NOT NULL,
[UpdateUser] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TravelMiles] [decimal] (28, 4) NOT NULL CONSTRAINT [dc_TMSTransitRating_TravelMiles] DEFAULT ((0)),
[ServiceSeconds] [decimal] (28, 4) NOT NULL CONSTRAINT [dc_TMSTransitRating_ServiceSeconds] DEFAULT ((0)),
[RestSeconds] [decimal] (28, 4) NOT NULL CONSTRAINT [dc_TMSTransitRating_RestSeconds] DEFAULT ((0)),
[StartTime] [datetime] NOT NULL CONSTRAINT [dc_TMSTransitRating_StartTime] DEFAULT (getdate()),
[EndTime] [datetime] NOT NULL CONSTRAINT [dc_TMSTransitRating_EndTime] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSTransitRating] ADD CONSTRAINT [PK_TMSTransitRating] PRIMARY KEY CLUSTERED ([RateId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSTransitRating] ADD CONSTRAINT [IX_TMSTransitRating_TransitID_OrderId_ShipId_IsSellRate] UNIQUE NONCLUSTERED ([TransitID], [OrderId], [ShipId], [IsSellRate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSTransitRating] ADD CONSTRAINT [FK_TMSTransitRating_TMSOrder] FOREIGN KEY ([OrderId]) REFERENCES [dbo].[TMSOrder] ([OrderId])
GO
ALTER TABLE [dbo].[TMSTransitRating] ADD CONSTRAINT [FK_TMSTransitRating_TMSShipment] FOREIGN KEY ([ShipId]) REFERENCES [dbo].[TMSShipment] ([ShipId])
GO
ALTER TABLE [dbo].[TMSTransitRating] ADD CONSTRAINT [FK_TMSTransitRating_TMSTransit] FOREIGN KEY ([TransitID]) REFERENCES [dbo].[TMSTransit] ([TransitID])
GO
GRANT DELETE ON  [dbo].[TMSTransitRating] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSTransitRating] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSTransitRating] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSTransitRating] TO [public]
GO
