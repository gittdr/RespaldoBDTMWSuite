CREATE TABLE [dbo].[PlanningBoardChild]
(
[PbcId] [int] NOT NULL,
[BoardType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ViewName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlanningBoardChild] ADD CONSTRAINT [PK_PlanningBoardChild] PRIMARY KEY CLUSTERED ([PbcId], [BoardType]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PlanningBoardChild] TO [public]
GO
GRANT INSERT ON  [dbo].[PlanningBoardChild] TO [public]
GO
GRANT REFERENCES ON  [dbo].[PlanningBoardChild] TO [public]
GO
GRANT SELECT ON  [dbo].[PlanningBoardChild] TO [public]
GO
GRANT UPDATE ON  [dbo].[PlanningBoardChild] TO [public]
GO
