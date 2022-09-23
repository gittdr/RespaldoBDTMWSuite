CREATE TABLE [dbo].[dwFleetAvailabilitySamplingID]
(
[SamplingID] [int] NOT NULL IDENTITY(1, 1),
[SamplingDate] [datetime] NULL,
[dwTimestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dwFleetAvailabilitySamplingID] ADD CONSTRAINT [PK__dwFleetAvailabil__09153BED] PRIMARY KEY CLUSTERED ([SamplingID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dwFleetAvailabilitySamplingID] TO [public]
GO
GRANT INSERT ON  [dbo].[dwFleetAvailabilitySamplingID] TO [public]
GO
GRANT SELECT ON  [dbo].[dwFleetAvailabilitySamplingID] TO [public]
GO
GRANT UPDATE ON  [dbo].[dwFleetAvailabilitySamplingID] TO [public]
GO
