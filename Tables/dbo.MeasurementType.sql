CREATE TABLE [dbo].[MeasurementType]
(
[MeasurementId] [smallint] NOT NULL,
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MeasurementType] ADD CONSTRAINT [PK_MeasurementType] PRIMARY KEY CLUSTERED ([MeasurementId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MeasurementType] TO [public]
GO
GRANT INSERT ON  [dbo].[MeasurementType] TO [public]
GO
GRANT SELECT ON  [dbo].[MeasurementType] TO [public]
GO
GRANT UPDATE ON  [dbo].[MeasurementType] TO [public]
GO
