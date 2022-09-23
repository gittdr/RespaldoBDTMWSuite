CREATE TABLE [dbo].[PlanningBoardConfigApp]
(
[AppName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Direction] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColumnName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlanningBoardConfigApp] ADD CONSTRAINT [PK_PlanningBoardConfigApp] PRIMARY KEY CLUSTERED ([AppName], [Direction], [ColumnName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PlanningBoardConfigApp] TO [public]
GO
GRANT INSERT ON  [dbo].[PlanningBoardConfigApp] TO [public]
GO
GRANT REFERENCES ON  [dbo].[PlanningBoardConfigApp] TO [public]
GO
GRANT SELECT ON  [dbo].[PlanningBoardConfigApp] TO [public]
GO
GRANT UPDATE ON  [dbo].[PlanningBoardConfigApp] TO [public]
GO
