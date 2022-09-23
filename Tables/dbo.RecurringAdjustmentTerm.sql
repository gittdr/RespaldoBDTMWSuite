CREATE TABLE [dbo].[RecurringAdjustmentTerm]
(
[RecurringAdjustmentTermId] [int] NOT NULL,
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RecurringAdjustmentTerm] ADD CONSTRAINT [PK_dbo.RecurringAdjustmentTerm] PRIMARY KEY CLUSTERED ([RecurringAdjustmentTermId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RecurringAdjustmentTerm] TO [public]
GO
GRANT INSERT ON  [dbo].[RecurringAdjustmentTerm] TO [public]
GO
GRANT SELECT ON  [dbo].[RecurringAdjustmentTerm] TO [public]
GO
GRANT UPDATE ON  [dbo].[RecurringAdjustmentTerm] TO [public]
GO
