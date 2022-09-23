CREATE TABLE [dbo].[IntegrationServiceOptimizationRequestsOrderData]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[RequestLegHeadersId] [int] NOT NULL,
[OrderCallBackIntegrationAPI] [varchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderCallBackStart] [datetime] NULL,
[OrderCallBackEnd] [datetime] NULL,
[OrderCallBackStatus] [int] NOT NULL CONSTRAINT [DF_OrderCallBackStatus] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IntegrationServiceOptimizationRequestsOrderData] ADD CONSTRAINT [PK_IntegrationServiceOptimizationRequestsOrderData] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IntegrationServiceOptimizationRequestsOrderData] ADD CONSTRAINT [FK_IntegrationServiceOptimizationRequestsOrderData] FOREIGN KEY ([RequestLegHeadersId]) REFERENCES [dbo].[IntegrationServiceOptimizationRequestsLegHeaders] ([Id])
GO
GRANT DELETE ON  [dbo].[IntegrationServiceOptimizationRequestsOrderData] TO [public]
GO
GRANT INSERT ON  [dbo].[IntegrationServiceOptimizationRequestsOrderData] TO [public]
GO
GRANT REFERENCES ON  [dbo].[IntegrationServiceOptimizationRequestsOrderData] TO [public]
GO
GRANT SELECT ON  [dbo].[IntegrationServiceOptimizationRequestsOrderData] TO [public]
GO
GRANT UPDATE ON  [dbo].[IntegrationServiceOptimizationRequestsOrderData] TO [public]
GO
