CREATE TABLE [dbo].[PlanningBoardType]
(
[BoardType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ParentBoardType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsNestedBoard] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ApplicationName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlanningBoardType] ADD CONSTRAINT [PK_PlanningBoardType] PRIMARY KEY CLUSTERED ([BoardType]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PlanningBoardType] TO [public]
GO
GRANT INSERT ON  [dbo].[PlanningBoardType] TO [public]
GO
GRANT REFERENCES ON  [dbo].[PlanningBoardType] TO [public]
GO
GRANT SELECT ON  [dbo].[PlanningBoardType] TO [public]
GO
GRANT UPDATE ON  [dbo].[PlanningBoardType] TO [public]
GO
