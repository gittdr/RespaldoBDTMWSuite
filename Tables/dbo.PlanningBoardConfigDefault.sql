CREATE TABLE [dbo].[PlanningBoardConfigDefault]
(
[PbcId] [int] NOT NULL,
[BoardType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EntityType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EntityName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlanningBoardConfigDefault] ADD CONSTRAINT [PK_PlanningBoardConfigDefault] PRIMARY KEY CLUSTERED ([PbcId], [EntityType], [EntityName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PlanningBoardConfigDefault] TO [public]
GO
GRANT INSERT ON  [dbo].[PlanningBoardConfigDefault] TO [public]
GO
GRANT SELECT ON  [dbo].[PlanningBoardConfigDefault] TO [public]
GO
GRANT UPDATE ON  [dbo].[PlanningBoardConfigDefault] TO [public]
GO
