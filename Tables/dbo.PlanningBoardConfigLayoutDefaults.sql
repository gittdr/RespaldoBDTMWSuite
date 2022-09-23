CREATE TABLE [dbo].[PlanningBoardConfigLayoutDefaults]
(
[PbcId] [int] NOT NULL,
[EntityType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EntityName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LayoutObject] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LayoutType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LayoutID] [bigint] NOT NULL,
[CreatedOn] [datetime] NOT NULL,
[CreatedBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedOn] [datetime] NOT NULL,
[LastUpdatedBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlanningBoardConfigLayoutDefaults] ADD CONSTRAINT [PK_PlanningBoardConfigLayoutDefaults] PRIMARY KEY CLUSTERED ([PbcId], [EntityType], [EntityName], [LayoutObject]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PlanningBoardConfigLayoutDefaults] TO [public]
GO
GRANT INSERT ON  [dbo].[PlanningBoardConfigLayoutDefaults] TO [public]
GO
GRANT REFERENCES ON  [dbo].[PlanningBoardConfigLayoutDefaults] TO [public]
GO
GRANT SELECT ON  [dbo].[PlanningBoardConfigLayoutDefaults] TO [public]
GO
GRANT UPDATE ON  [dbo].[PlanningBoardConfigLayoutDefaults] TO [public]
GO
