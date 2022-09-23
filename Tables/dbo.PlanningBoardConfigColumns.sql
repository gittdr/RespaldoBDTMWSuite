CREATE TABLE [dbo].[PlanningBoardConfigColumns]
(
[PbcId] [int] NOT NULL,
[ViewName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColumnName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OverrideName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DisplaySequence] [int] NOT NULL,
[VisibleFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedOn] [datetime] NULL,
[LastUpdateBy] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedOn] [datetime] NULL,
[DefaultValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrueValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FalseValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdditionalColumn] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TypeOfSearch] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[labeldefinition] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlanningBoardConfigColumns] ADD CONSTRAINT [PK_PlanningBoardConfigColumns] PRIMARY KEY CLUSTERED ([PbcId], [ViewName], [ColumnName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PlanningBoardConfigColumns] TO [public]
GO
GRANT INSERT ON  [dbo].[PlanningBoardConfigColumns] TO [public]
GO
GRANT SELECT ON  [dbo].[PlanningBoardConfigColumns] TO [public]
GO
GRANT UPDATE ON  [dbo].[PlanningBoardConfigColumns] TO [public]
GO
