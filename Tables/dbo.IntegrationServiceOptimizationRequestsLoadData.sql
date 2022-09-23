CREATE TABLE [dbo].[IntegrationServiceOptimizationRequestsLoadData]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[RequestLegHeadersId] [int] NOT NULL,
[LoadCallBackIntegrationAPI] [varchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadCallBackStart] [datetime] NULL,
[LoadCallBackEnd] [datetime] NULL,
[LoadCallBackStatus] [int] NOT NULL CONSTRAINT [DF_LoadCallBackStatus] DEFAULT ((0)),
[LoadCallBackBatchTransactionNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadCallBackAssigned] [int] NULL,
[LoadCallBackConsolidation] [int] NULL,
[LoadCallBackCrossDock] [int] NULL,
[RouteModificationDuration] [decimal] (9, 6) NULL,
[RoutePersistanceDuration] [decimal] (9, 6) NULL,
[MileageLookUpDuration] [decimal] (9, 6) NULL,
[UpdateMoveDuration] [decimal] (9, 6) NULL,
[After3GPostProcedureDuration] [decimal] (9, 6) NULL,
[CallBackRatingStart] [datetime] NULL,
[CallBackRatingEnd] [datetime] NULL,
[CallBackRatingStatus] [int] NOT NULL CONSTRAINT [DF_CallBackRatingStatus] DEFAULT ((0)),
[RatingDuration] [decimal] (9, 6) NULL,
[CallBackRatingMessages] [varchar] (4096) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IntegrationServiceOptimizationRequestsLoadData] ADD CONSTRAINT [PK_IntegrationServiceOptimizationRequestsLoadData] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IntegrationServiceOptimizationRequestsLoadData] ADD CONSTRAINT [FK_IntegrationServiceOptimizationRequestsLoadData] FOREIGN KEY ([RequestLegHeadersId]) REFERENCES [dbo].[IntegrationServiceOptimizationRequestsLegHeaders] ([Id])
GO
GRANT DELETE ON  [dbo].[IntegrationServiceOptimizationRequestsLoadData] TO [public]
GO
GRANT INSERT ON  [dbo].[IntegrationServiceOptimizationRequestsLoadData] TO [public]
GO
GRANT REFERENCES ON  [dbo].[IntegrationServiceOptimizationRequestsLoadData] TO [public]
GO
GRANT SELECT ON  [dbo].[IntegrationServiceOptimizationRequestsLoadData] TO [public]
GO
GRANT UPDATE ON  [dbo].[IntegrationServiceOptimizationRequestsLoadData] TO [public]
GO
