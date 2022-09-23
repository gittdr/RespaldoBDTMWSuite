CREATE TABLE [dbo].[core_laneregion]
(
[RegionId] [int] NOT NULL IDENTITY(1, 1),
[RegionName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[core_laneregion] ADD CONSTRAINT [PK_core_laneregion] PRIMARY KEY CLUSTERED ([RegionId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_core_laneregion_regionname] ON [dbo].[core_laneregion] ([RegionName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[core_laneregion] TO [public]
GO
GRANT INSERT ON  [dbo].[core_laneregion] TO [public]
GO
GRANT SELECT ON  [dbo].[core_laneregion] TO [public]
GO
GRANT UPDATE ON  [dbo].[core_laneregion] TO [public]
GO
