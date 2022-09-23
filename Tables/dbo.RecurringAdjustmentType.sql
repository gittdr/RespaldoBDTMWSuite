CREATE TABLE [dbo].[RecurringAdjustmentType]
(
[RecurringAdjustmentTypeId] [int] NOT NULL,
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RecurringAdjustmentType] ADD CONSTRAINT [PK_dbo.RecurringAdjustmentType] PRIMARY KEY CLUSTERED ([RecurringAdjustmentTypeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RecurringAdjustmentType] TO [public]
GO
GRANT INSERT ON  [dbo].[RecurringAdjustmentType] TO [public]
GO
GRANT SELECT ON  [dbo].[RecurringAdjustmentType] TO [public]
GO
GRANT UPDATE ON  [dbo].[RecurringAdjustmentType] TO [public]
GO
