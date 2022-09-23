CREATE TABLE [dbo].[PlanningBoardRequired]
(
[BoardType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColumnName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsPrimaryKey] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsRemovable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PrimaryKeyTable] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PrimaryKeyColumn] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlanningBoardRequired] ADD CONSTRAINT [PK_PlanningBoardRequired] PRIMARY KEY CLUSTERED ([BoardType], [ColumnName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PlanningBoardRequired] TO [public]
GO
GRANT INSERT ON  [dbo].[PlanningBoardRequired] TO [public]
GO
GRANT REFERENCES ON  [dbo].[PlanningBoardRequired] TO [public]
GO
GRANT SELECT ON  [dbo].[PlanningBoardRequired] TO [public]
GO
GRANT UPDATE ON  [dbo].[PlanningBoardRequired] TO [public]
GO
