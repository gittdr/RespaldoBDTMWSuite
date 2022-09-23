CREATE TABLE [dbo].[MappingLandmarkSetShapePoints]
(
[mlsp_id] [int] NOT NULL IDENTITY(1, 1),
[mls_id] [int] NOT NULL,
[mlsp_Sequence] [int] NOT NULL,
[mlsp_Longitude] [float] NOT NULL,
[mlsp_Latitude] [float] NOT NULL,
[mlsp_CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mlsp_CreatedOn] [datetime] NOT NULL,
[mlsp_LastUpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mlsp_LastUpdatedOn] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MappingLandmarkSetShapePoints] TO [public]
GO
GRANT INSERT ON  [dbo].[MappingLandmarkSetShapePoints] TO [public]
GO
GRANT SELECT ON  [dbo].[MappingLandmarkSetShapePoints] TO [public]
GO
GRANT UPDATE ON  [dbo].[MappingLandmarkSetShapePoints] TO [public]
GO
