CREATE TABLE [dbo].[RecurringAdjustmentInterestTerm]
(
[RecurringAdjustmentInterestTermId] [int] NOT NULL,
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RecurringAdjustmentInterestTerm] ADD CONSTRAINT [PK_dbo.RecurringAdjustmentInterestTerm] PRIMARY KEY CLUSTERED ([RecurringAdjustmentInterestTermId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RecurringAdjustmentInterestTerm] TO [public]
GO
GRANT INSERT ON  [dbo].[RecurringAdjustmentInterestTerm] TO [public]
GO
GRANT SELECT ON  [dbo].[RecurringAdjustmentInterestTerm] TO [public]
GO
GRANT UPDATE ON  [dbo].[RecurringAdjustmentInterestTerm] TO [public]
GO
