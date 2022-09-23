CREATE TABLE [dbo].[FreightLegNeedingRouting]
(
[FreightLegId] [bigint] NOT NULL,
[CreatedDate] [datetime2] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightLegNeedingRouting] ADD CONSTRAINT [PK_FreightOrderLegNeedingRouting] PRIMARY KEY CLUSTERED ([FreightLegId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightLegNeedingRouting] ADD CONSTRAINT [FK_FreightLegNeedingRouting_FreightLeg] FOREIGN KEY ([FreightLegId]) REFERENCES [dbo].[FreightLeg] ([FreightLegId])
GO
GRANT DELETE ON  [dbo].[FreightLegNeedingRouting] TO [public]
GO
GRANT INSERT ON  [dbo].[FreightLegNeedingRouting] TO [public]
GO
GRANT SELECT ON  [dbo].[FreightLegNeedingRouting] TO [public]
GO
GRANT UPDATE ON  [dbo].[FreightLegNeedingRouting] TO [public]
GO
