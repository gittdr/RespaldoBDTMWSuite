CREATE TABLE [dbo].[MappingLandmarkSets]
(
[ml_id] [int] NOT NULL IDENTITY(1, 1),
[ml_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ml_MinimumZoom] [int] NOT NULL,
[ml_CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ml_CreatedOn] [datetime] NOT NULL,
[ml_LastUpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ml_LastUpdatedOn] [datetime] NULL,
[ml_IsSystem] [bit] NOT NULL CONSTRAINT [DF_MappingLandmarkSets_ml_IsSystem] DEFAULT ((0))
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MappingLandmarkSets] TO [public]
GO
GRANT INSERT ON  [dbo].[MappingLandmarkSets] TO [public]
GO
GRANT SELECT ON  [dbo].[MappingLandmarkSets] TO [public]
GO
GRANT UPDATE ON  [dbo].[MappingLandmarkSets] TO [public]
GO
