CREATE TABLE [dbo].[TMSRouting]
(
[RouteID] [int] NOT NULL IDENTITY(1, 1),
[BatchId] [bigint] NOT NULL,
[RouteName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StopCount] [int] NOT NULL,
[RouteDistance] [decimal] (12, 2) NULL,
[RouteTime] [decimal] (12, 2) NULL,
[RouteCost] [money] NULL,
[CapacityQuantity1] [decimal] (12, 2) NULL,
[CapacityQuantity2] [decimal] (12, 2) NULL,
[CapacityQuantity3] [decimal] (12, 2) NULL,
[Mode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSRouting] ADD CONSTRAINT [PK_TMSRouting] PRIMARY KEY CLUSTERED ([RouteID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSRouting] WITH NOCHECK ADD CONSTRAINT [fk_TMSRouting_BatchId] FOREIGN KEY ([BatchId]) REFERENCES [dbo].[TMSBatch] ([BatchId])
GO
GRANT DELETE ON  [dbo].[TMSRouting] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSRouting] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSRouting] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSRouting] TO [public]
GO
