CREATE TABLE [dbo].[RatingRuleApplyActionType]
(
[RatingRuleApplyActionTypeId] [int] NOT NULL,
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RatingRuleApplyActionType] ADD CONSTRAINT [PK_RatingRuleApplyActionType] PRIMARY KEY CLUSTERED ([RatingRuleApplyActionTypeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RatingRuleApplyActionType] TO [public]
GO
GRANT INSERT ON  [dbo].[RatingRuleApplyActionType] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RatingRuleApplyActionType] TO [public]
GO
GRANT SELECT ON  [dbo].[RatingRuleApplyActionType] TO [public]
GO
GRANT UPDATE ON  [dbo].[RatingRuleApplyActionType] TO [public]
GO
