CREATE TABLE [dbo].[TMSRoutingStops]
(
[RouteID] [int] NOT NULL,
[Sequence] [int] NOT NULL,
[BatchId] [bigint] NOT NULL,
[StopType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderId] [int] NULL,
[ArrivalDate] [datetime] NOT NULL,
[DepartureDate] [datetime] NOT NULL,
[Distance] [decimal] (12, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSRoutingStops] ADD CONSTRAINT [PK_TMSRoutingStops] PRIMARY KEY CLUSTERED ([RouteID], [Sequence]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSRoutingStops] WITH NOCHECK ADD CONSTRAINT [fk_TMSRoutingStops_BatchId] FOREIGN KEY ([BatchId]) REFERENCES [dbo].[TMSBatch] ([BatchId])
GO
ALTER TABLE [dbo].[TMSRoutingStops] ADD CONSTRAINT [fk_TMSRoutingStops_OrderId] FOREIGN KEY ([OrderId]) REFERENCES [dbo].[TMSOrder] ([OrderId])
GO
ALTER TABLE [dbo].[TMSRoutingStops] ADD CONSTRAINT [fk_TMSRoutingStops_RouteID] FOREIGN KEY ([RouteID]) REFERENCES [dbo].[TMSRouting] ([RouteID])
GO
GRANT DELETE ON  [dbo].[TMSRoutingStops] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSRoutingStops] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSRoutingStops] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSRoutingStops] TO [public]
GO
