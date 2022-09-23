CREATE TABLE [dbo].[MappingLandmarkSetLines]
(
[mll_id] [int] NOT NULL IDENTITY(1, 1),
[ml_id] [int] NOT NULL,
[mll_Label] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mll_Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mll_StrokeColor] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mll_StrokeOpacity] [int] NULL,
[mll_StrokeWeight] [int] NULL,
[mll_CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mll_CreatedOn] [datetime] NOT NULL,
[mll_LastUpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mll_LastUpdatedOn] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MappingLandmarkSetLines] TO [public]
GO
GRANT INSERT ON  [dbo].[MappingLandmarkSetLines] TO [public]
GO
GRANT SELECT ON  [dbo].[MappingLandmarkSetLines] TO [public]
GO
GRANT UPDATE ON  [dbo].[MappingLandmarkSetLines] TO [public]
GO
