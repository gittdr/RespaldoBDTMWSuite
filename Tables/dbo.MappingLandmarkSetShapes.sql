CREATE TABLE [dbo].[MappingLandmarkSetShapes]
(
[mls_id] [int] NOT NULL IDENTITY(1, 1),
[ml_id] [int] NOT NULL,
[mls_Label] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mls_Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mls_StrokeColor] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mls_StrokeOpacity] [int] NULL,
[mls_StrokeWeight] [int] NULL,
[mls_FillColor] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mls_FillOpacity] [int] NULL,
[mls_Radius] [float] NULL,
[mls_CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mls_CreatedOn] [datetime] NOT NULL,
[mls_LastUpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mls_LastUpdatedOn] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MappingLandmarkSetShapes] TO [public]
GO
GRANT INSERT ON  [dbo].[MappingLandmarkSetShapes] TO [public]
GO
GRANT SELECT ON  [dbo].[MappingLandmarkSetShapes] TO [public]
GO
GRANT UPDATE ON  [dbo].[MappingLandmarkSetShapes] TO [public]
GO
