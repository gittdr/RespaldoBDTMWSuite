CREATE TABLE [dbo].[IntegrationServiceOptimizationRequests_LegHeaders_Old]
(
[OptimizationRequestId] [int] NOT NULL,
[LegHeaderNumber] [int] NOT NULL,
[IsLocked] [bit] NOT NULL,
[IsProcessed] [bit] NULL CONSTRAINT [DF__Integrati__IsPro__15A49248] DEFAULT ((0)),
[OrderHeaderNumber] [int] NULL CONSTRAINT [DF__Integrati__Order__1698B681] DEFAULT ((0)),
[OptimizedLegHeaderNumber] [int] NULL CONSTRAINT [DF__Integrati__Optim__178CDABA] DEFAULT ((0)),
[RouteId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdditionalInfo] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedOn] [datetime] NULL,
[LastUpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedOn] [datetime] NULL,
[Id] [int] NOT NULL IDENTITY(1, 1),
[ShipWithGroupName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IntegrationServiceOptimizationRequests_LegHeaders_Old] ADD CONSTRAINT [PK_IntegrationServiceOptimizationRequests_LegHeaders] PRIMARY KEY CLUSTERED ([LegHeaderNumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[IntegrationServiceOptimizationRequests_LegHeaders_Old] TO [public]
GO
GRANT INSERT ON  [dbo].[IntegrationServiceOptimizationRequests_LegHeaders_Old] TO [public]
GO
GRANT REFERENCES ON  [dbo].[IntegrationServiceOptimizationRequests_LegHeaders_Old] TO [public]
GO
GRANT SELECT ON  [dbo].[IntegrationServiceOptimizationRequests_LegHeaders_Old] TO [public]
GO
GRANT UPDATE ON  [dbo].[IntegrationServiceOptimizationRequests_LegHeaders_Old] TO [public]
GO
