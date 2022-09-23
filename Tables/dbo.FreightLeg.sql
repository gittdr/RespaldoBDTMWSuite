CREATE TABLE [dbo].[FreightLeg]
(
[FreightLegId] [bigint] NOT NULL IDENTITY(1, 1),
[FreightOrderId] [bigint] NOT NULL,
[LegSequence] [tinyint] NOT NULL,
[OptimizeStatusId] [tinyint] NOT NULL,
[OptimizeStartedDate] [datetime2] NULL,
[OptimizeCompletedDate] [datetime2] NULL,
[PickupStopId] [bigint] NOT NULL,
[DeliveryStopId] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightLeg] ADD CONSTRAINT [PK_FreightOrderLeg] PRIMARY KEY CLUSTERED ([FreightLegId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_DeliveryStopId] ON [dbo].[FreightLeg] ([DeliveryStopId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_FreightOrderId] ON [dbo].[FreightLeg] ([FreightOrderId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_PickupStopId] ON [dbo].[FreightLeg] ([PickupStopId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightLeg] ADD CONSTRAINT [FK_FreightLeg_DeliveryStopId] FOREIGN KEY ([DeliveryStopId]) REFERENCES [dbo].[FreightLegStop] ([FreightLegStopId])
GO
ALTER TABLE [dbo].[FreightLeg] ADD CONSTRAINT [FK_FreightLeg_FreightLegOptimizeStatus] FOREIGN KEY ([OptimizeStatusId]) REFERENCES [dbo].[FreightLegOptimizeStatus] ([OptimizeStatusId])
GO
ALTER TABLE [dbo].[FreightLeg] ADD CONSTRAINT [FK_FreightLeg_PickupStopId] FOREIGN KEY ([PickupStopId]) REFERENCES [dbo].[FreightLegStop] ([FreightLegStopId])
GO
GRANT DELETE ON  [dbo].[FreightLeg] TO [public]
GO
GRANT INSERT ON  [dbo].[FreightLeg] TO [public]
GO
GRANT SELECT ON  [dbo].[FreightLeg] TO [public]
GO
GRANT UPDATE ON  [dbo].[FreightLeg] TO [public]
GO
