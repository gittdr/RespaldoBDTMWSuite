CREATE TABLE [dbo].[IntegrationServiceOptimizationRequestsRequestStatus]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[RequestLegHeadersId] [int] NOT NULL,
[LegHeaderNumber] [int] NOT NULL,
[OrderCreationIntegrationAPI] [varchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SendStart] [datetime] NULL,
[SendEnd] [datetime] NULL,
[Sending] [int] NULL CONSTRAINT [DF_Sending] DEFAULT ((0)),
[ModelCreationDuration] [decimal] (9, 6) NULL,
[ModelSendDuration] [decimal] (9, 6) NULL,
[Sent] [int] NULL CONSTRAINT [DF_Sent] DEFAULT ((0)),
[SendingMessages] [varchar] (4096) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IntegrationServiceOptimizationRequestsRequestStatus] ADD CONSTRAINT [PK_IntegrationServiceOptimizationRequestsRequestStatus] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IntegrationServiceOptimizationRequestsRequestStatus] ADD CONSTRAINT [FK_IntegrationServiceOptimizationRequestsRequestStatus] FOREIGN KEY ([RequestLegHeadersId]) REFERENCES [dbo].[IntegrationServiceOptimizationRequestsLegHeaders] ([Id])
GO
GRANT DELETE ON  [dbo].[IntegrationServiceOptimizationRequestsRequestStatus] TO [public]
GO
GRANT INSERT ON  [dbo].[IntegrationServiceOptimizationRequestsRequestStatus] TO [public]
GO
GRANT REFERENCES ON  [dbo].[IntegrationServiceOptimizationRequestsRequestStatus] TO [public]
GO
GRANT SELECT ON  [dbo].[IntegrationServiceOptimizationRequestsRequestStatus] TO [public]
GO
GRANT UPDATE ON  [dbo].[IntegrationServiceOptimizationRequestsRequestStatus] TO [public]
GO
