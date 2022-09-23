CREATE TABLE [dbo].[RatingCostHeader]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[RatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RatedDate] [datetime2] NOT NULL,
[RatingSource] [tinyint] NOT NULL CONSTRAINT [DF__RatingCos__Ratin__53A1C4C1] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RatingCostHeader] ADD CONSTRAINT [PK_RatingCostHeader] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RatingCostHeader] TO [public]
GO
GRANT INSERT ON  [dbo].[RatingCostHeader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RatingCostHeader] TO [public]
GO
GRANT SELECT ON  [dbo].[RatingCostHeader] TO [public]
GO
GRANT UPDATE ON  [dbo].[RatingCostHeader] TO [public]
GO
