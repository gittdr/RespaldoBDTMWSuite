CREATE TABLE [dbo].[FreightOrderMeasurement]
(
[FreightOrderMeasurementId] [bigint] NOT NULL IDENTITY(1, 1),
[FreightOrderLineItemId] [bigint] NOT NULL,
[MeasurementId] [smallint] NOT NULL,
[Unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [decimal] (19, 4) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrderMeasurement] ADD CONSTRAINT [PK_FreightOrderMeasurement] PRIMARY KEY CLUSTERED ([FreightOrderMeasurementId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_FreightOrderLineItemRefNumId] ON [dbo].[FreightOrderMeasurement] ([FreightOrderLineItemId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrderMeasurement] ADD CONSTRAINT [FK_FreightOrderMeasurement_FreightOrderLineItem] FOREIGN KEY ([FreightOrderLineItemId]) REFERENCES [dbo].[FreightOrderLineItem] ([FreightOrderLineItemId])
GO
ALTER TABLE [dbo].[FreightOrderMeasurement] ADD CONSTRAINT [FK_FreightOrderMeasurement_MeasurementType] FOREIGN KEY ([MeasurementId]) REFERENCES [dbo].[MeasurementType] ([MeasurementId])
GO
GRANT DELETE ON  [dbo].[FreightOrderMeasurement] TO [public]
GO
GRANT INSERT ON  [dbo].[FreightOrderMeasurement] TO [public]
GO
GRANT SELECT ON  [dbo].[FreightOrderMeasurement] TO [public]
GO
GRANT UPDATE ON  [dbo].[FreightOrderMeasurement] TO [public]
GO
