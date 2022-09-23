CREATE TABLE [dbo].[MappingLandmarkSetPoints]
(
[mlp_id] [int] NOT NULL IDENTITY(1, 1),
[ml_id] [int] NOT NULL,
[mlp_Label] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mlp_Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mlp_Icon] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mlp_Longitude] [float] NOT NULL,
[mlp_Latitude] [float] NOT NULL,
[mlp_CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mlp_CreatedOn] [datetime] NOT NULL,
[mlp_LastUpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mlp_LastUpdatedOn] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MappingLandmarkSetPoints] TO [public]
GO
GRANT INSERT ON  [dbo].[MappingLandmarkSetPoints] TO [public]
GO
GRANT SELECT ON  [dbo].[MappingLandmarkSetPoints] TO [public]
GO
GRANT UPDATE ON  [dbo].[MappingLandmarkSetPoints] TO [public]
GO
