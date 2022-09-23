CREATE TABLE [dbo].[PlanningBoardMissingColumns]
(
[PbcId] [int] NOT NULL,
[ViewName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Boardtype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MissingColName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsInView] [bit] NULL,
[ViewType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MissingType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlanningBoardMissingColumns] ADD CONSTRAINT [UX_PlanningBoardMissingColumns] UNIQUE NONCLUSTERED ([PbcId], [Boardtype], [MissingColName], [ViewType], [MissingType]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PlanningBoardMissingColumns] TO [public]
GO
GRANT INSERT ON  [dbo].[PlanningBoardMissingColumns] TO [public]
GO
GRANT REFERENCES ON  [dbo].[PlanningBoardMissingColumns] TO [public]
GO
GRANT SELECT ON  [dbo].[PlanningBoardMissingColumns] TO [public]
GO
GRANT UPDATE ON  [dbo].[PlanningBoardMissingColumns] TO [public]
GO
