CREATE TABLE [dbo].[RecurringAdjustmentDetailType]
(
[RecurringAdjustmentDetailTypeId] [int] NOT NULL,
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RecurringAdjustmentDetailType] ADD CONSTRAINT [PK_dbo.RecurringAdjustmentDetailType] PRIMARY KEY CLUSTERED ([RecurringAdjustmentDetailTypeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RecurringAdjustmentDetailType] TO [public]
GO
GRANT INSERT ON  [dbo].[RecurringAdjustmentDetailType] TO [public]
GO
GRANT SELECT ON  [dbo].[RecurringAdjustmentDetailType] TO [public]
GO
GRANT UPDATE ON  [dbo].[RecurringAdjustmentDetailType] TO [public]
GO
