CREATE TABLE [dbo].[PlanningBoardConfigWhere]
(
[PbcId] [int] NOT NULL,
[ColumnName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColumnWhere] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModeFlags] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlanningBoardConfigWhere] ADD CONSTRAINT [PK_PlanningBoardConfigWhere] PRIMARY KEY CLUSTERED ([PbcId], [ColumnName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PlanningBoardConfigWhere] TO [public]
GO
GRANT INSERT ON  [dbo].[PlanningBoardConfigWhere] TO [public]
GO
GRANT SELECT ON  [dbo].[PlanningBoardConfigWhere] TO [public]
GO
GRANT UPDATE ON  [dbo].[PlanningBoardConfigWhere] TO [public]
GO
