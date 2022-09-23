CREATE TABLE [dbo].[FreightOrder]
(
[FreightOrderId] [bigint] NOT NULL IDENTITY(1, 1),
[Source] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternalId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Branch] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillTo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BookedBy] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Contact] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AvailableDate] [datetime2] (3) NULL,
[PromisedDate] [datetime2] (3) NULL,
[PickupStopId] [bigint] NOT NULL,
[DeliveryStopId] [bigint] NOT NULL,
[ClusterGUID] [uniqueidentifier] NULL,
[FixedRouteDate] [date] NULL,
[Remark] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BranchId] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrder] ADD CONSTRAINT [PK_FreightOrder] PRIMARY KEY CLUSTERED ([FreightOrderId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ClusterGUID] ON [dbo].[FreightOrder] ([ClusterGUID]) WHERE ([ClusterGUID] IS NOT NULL) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_DeliveryStopId] ON [dbo].[FreightOrder] ([DeliveryStopId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ExternalId_Source] ON [dbo].[FreightOrder] ([ExternalId], [Source]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_FixedRouteDate_BranchId] ON [dbo].[FreightOrder] ([FixedRouteDate], [BranchId]) WHERE ([FixedRouteDate] IS NOT NULL) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_PickupStopId] ON [dbo].[FreightOrder] ([PickupStopId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrder] ADD CONSTRAINT [FK_FreightOrder_DeliveryStopId] FOREIGN KEY ([DeliveryStopId]) REFERENCES [dbo].[FreightOrderStop] ([FreightOrderStopId])
GO
ALTER TABLE [dbo].[FreightOrder] ADD CONSTRAINT [FK_FreightOrder_PickupStopId] FOREIGN KEY ([PickupStopId]) REFERENCES [dbo].[FreightOrderStop] ([FreightOrderStopId])
GO
GRANT DELETE ON  [dbo].[FreightOrder] TO [public]
GO
GRANT INSERT ON  [dbo].[FreightOrder] TO [public]
GO
GRANT SELECT ON  [dbo].[FreightOrder] TO [public]
GO
GRANT UPDATE ON  [dbo].[FreightOrder] TO [public]
GO
