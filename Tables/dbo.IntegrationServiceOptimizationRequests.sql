CREATE TABLE [dbo].[IntegrationServiceOptimizationRequests]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[BatchName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Locked] [bit] NULL CONSTRAINT [DF__Integrati__Locke__13BC49D6] DEFAULT ((0)),
[AdditionalInfo] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedOn] [datetime] NULL,
[LastUpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedOn] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IntegrationServiceOptimizationRequests] ADD CONSTRAINT [PK_IntegrationServiceOptimizationRequests] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_IntegrationServiceOptimizationRequests_Locked] ON [dbo].[IntegrationServiceOptimizationRequests] ([Locked]) INCLUDE ([Id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[IntegrationServiceOptimizationRequests] TO [public]
GO
GRANT INSERT ON  [dbo].[IntegrationServiceOptimizationRequests] TO [public]
GO
GRANT REFERENCES ON  [dbo].[IntegrationServiceOptimizationRequests] TO [public]
GO
GRANT SELECT ON  [dbo].[IntegrationServiceOptimizationRequests] TO [public]
GO
GRANT UPDATE ON  [dbo].[IntegrationServiceOptimizationRequests] TO [public]
GO
