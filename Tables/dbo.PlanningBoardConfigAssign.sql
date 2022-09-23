CREATE TABLE [dbo].[PlanningBoardConfigAssign]
(
[PbcId] [int] NOT NULL,
[AssignType] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AssignValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AccessLevel] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlanningBoardConfigAssign] ADD CONSTRAINT [PK_PlanningBoardConfigAssign] PRIMARY KEY CLUSTERED ([PbcId], [AssignType], [AssignValue]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PlanningBoardConfigAssign] TO [public]
GO
GRANT INSERT ON  [dbo].[PlanningBoardConfigAssign] TO [public]
GO
GRANT SELECT ON  [dbo].[PlanningBoardConfigAssign] TO [public]
GO
GRANT UPDATE ON  [dbo].[PlanningBoardConfigAssign] TO [public]
GO
