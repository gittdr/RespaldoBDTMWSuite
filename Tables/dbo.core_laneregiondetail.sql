CREATE TABLE [dbo].[core_laneregiondetail]
(
[DetailId] [int] NOT NULL IDENTITY(1, 1),
[RegionId] [int] NOT NULL,
[ZipPart] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[core_laneregiondetail] ADD CONSTRAINT [PK_core_laneregiondetail] PRIMARY KEY CLUSTERED ([DetailId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[core_laneregiondetail] ADD CONSTRAINT [FK_core_laneregiondetail_core_laneregion] FOREIGN KEY ([RegionId]) REFERENCES [dbo].[core_laneregion] ([RegionId]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[core_laneregiondetail] TO [public]
GO
GRANT INSERT ON  [dbo].[core_laneregiondetail] TO [public]
GO
GRANT SELECT ON  [dbo].[core_laneregiondetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[core_laneregiondetail] TO [public]
GO
