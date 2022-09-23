CREATE TABLE [dbo].[PlanningBoardConfig]
(
[PbcId] [int] NOT NULL IDENTITY(1, 1),
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BoardType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ViewName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DriverViewName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TractorViewName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrailerViewName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarrierViewName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedOn] [datetime] NULL,
[LastUpdateBy] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdateOn] [datetime] NULL,
[CriteriaFlags] [int] NULL,
[RelatedScreenDesignerID] [int] NULL,
[Filters] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PendingLoadViewName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsDefault] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ViewType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlanningBoardConfig] ADD CONSTRAINT [PK_PlanningBoardConfig] PRIMARY KEY CLUSTERED ([PbcId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PlanningBoardConfig] TO [public]
GO
GRANT INSERT ON  [dbo].[PlanningBoardConfig] TO [public]
GO
GRANT SELECT ON  [dbo].[PlanningBoardConfig] TO [public]
GO
GRANT UPDATE ON  [dbo].[PlanningBoardConfig] TO [public]
GO
