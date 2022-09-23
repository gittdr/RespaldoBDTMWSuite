CREATE TABLE [dbo].[MappingLandmarkSetLinePoints]
(
[mllp_id] [int] NOT NULL IDENTITY(1, 1),
[mll_id] [int] NOT NULL,
[mllp_Sequence] [int] NOT NULL,
[mllp_Longitude] [float] NOT NULL,
[mllp_Latitude] [float] NOT NULL,
[mllp_CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mllp_CreatedOn] [datetime] NOT NULL,
[mllp_LastUpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mllp_LastUpdatedOn] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MappingLandmarkSetLinePoints] TO [public]
GO
GRANT INSERT ON  [dbo].[MappingLandmarkSetLinePoints] TO [public]
GO
GRANT SELECT ON  [dbo].[MappingLandmarkSetLinePoints] TO [public]
GO
GRANT UPDATE ON  [dbo].[MappingLandmarkSetLinePoints] TO [public]
GO
