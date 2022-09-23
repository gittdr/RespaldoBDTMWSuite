CREATE TABLE [dbo].[RatingRuleRatingPhase]
(
[RatingRuleRatingPhaseId] [int] NOT NULL,
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RatingRuleRatingPhase] ADD CONSTRAINT [PK_RatingRuleRatingPhase] PRIMARY KEY CLUSTERED ([RatingRuleRatingPhaseId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RatingRuleRatingPhase] TO [public]
GO
GRANT INSERT ON  [dbo].[RatingRuleRatingPhase] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RatingRuleRatingPhase] TO [public]
GO
GRANT SELECT ON  [dbo].[RatingRuleRatingPhase] TO [public]
GO
GRANT UPDATE ON  [dbo].[RatingRuleRatingPhase] TO [public]
GO
