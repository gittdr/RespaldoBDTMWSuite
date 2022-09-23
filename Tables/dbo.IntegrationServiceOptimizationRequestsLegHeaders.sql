CREATE TABLE [dbo].[IntegrationServiceOptimizationRequestsLegHeaders]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[OptimizationRequestId] [int] NOT NULL,
[LegHeaderNumber] [int] NOT NULL,
[IsLocked] [bit] NOT NULL,
[IsProcessed] [bit] NULL CONSTRAINT [DF_IsProcessed] DEFAULT ((0)),
[OrderHeaderNumber] [int] NULL CONSTRAINT [DF_OrderHeaderNumber] DEFAULT ((0)),
[OptimizedLegHeaderNumber] [int] NULL CONSTRAINT [DF_OptimizedLegHeaderNumber] DEFAULT ((0)),
[ShipWithGroupName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SendCommodityCode] [int] NULL,
[SendReferenceNumbers] [int] NULL,
[AdditionalInfo] [varchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RouteId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedOn] [datetime] NULL,
[LastUpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedOn] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IntegrationServiceOptimizationRequestsLegHeaders] ADD CONSTRAINT [PK_IntegrationServiceOptimizationRequestsLegHeaders] PRIMARY KEY NONCLUSTERED ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_IntegrationServiceOptimizationRequestsLegHeaders_IsProcessedIsLocked] ON [dbo].[IntegrationServiceOptimizationRequestsLegHeaders] ([IsProcessed], [IsLocked]) INCLUDE ([OptimizationRequestId], [LegHeaderNumber]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_IntegrationServiceOptimizationRequestsLegHeaders_LegHeaders] ON [dbo].[IntegrationServiceOptimizationRequestsLegHeaders] ([LegHeaderNumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_IntegrationServiceOptimizationRequestsLegHeaders_OptimizationRequestId] ON [dbo].[IntegrationServiceOptimizationRequestsLegHeaders] ([OptimizationRequestId]) INCLUDE ([LegHeaderNumber]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IntegrationServiceOptimizationRequestsLegHeaders] ADD CONSTRAINT [FK_IntegrationServiceOptimizationRequestsLegHeaders] FOREIGN KEY ([OptimizationRequestId]) REFERENCES [dbo].[IntegrationServiceOptimizationRequests] ([Id])
GO
GRANT DELETE ON  [dbo].[IntegrationServiceOptimizationRequestsLegHeaders] TO [public]
GO
GRANT INSERT ON  [dbo].[IntegrationServiceOptimizationRequestsLegHeaders] TO [public]
GO
GRANT REFERENCES ON  [dbo].[IntegrationServiceOptimizationRequestsLegHeaders] TO [public]
GO
GRANT SELECT ON  [dbo].[IntegrationServiceOptimizationRequestsLegHeaders] TO [public]
GO
GRANT UPDATE ON  [dbo].[IntegrationServiceOptimizationRequestsLegHeaders] TO [public]
GO
