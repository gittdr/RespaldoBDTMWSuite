CREATE TABLE [dbo].[RecurringAdjustmentBasis]
(
[RecurringAdjustmentBasisId] [int] NOT NULL,
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RecurringAdjustmentBasis] ADD CONSTRAINT [PK_dbo.RecurringAdjustmentBasis] PRIMARY KEY CLUSTERED ([RecurringAdjustmentBasisId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RecurringAdjustmentBasis] TO [public]
GO
GRANT INSERT ON  [dbo].[RecurringAdjustmentBasis] TO [public]
GO
GRANT SELECT ON  [dbo].[RecurringAdjustmentBasis] TO [public]
GO
GRANT UPDATE ON  [dbo].[RecurringAdjustmentBasis] TO [public]
GO
