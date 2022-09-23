CREATE TABLE [dbo].[RecurringAdjustmentHeaderStatus]
(
[RecurringAdjustmentHeaderStatusId] [int] NOT NULL,
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RecurringAdjustmentHeaderStatus] ADD CONSTRAINT [PK_dbo.RecurringAdjustmentHeaderStatus] PRIMARY KEY CLUSTERED ([RecurringAdjustmentHeaderStatusId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RecurringAdjustmentHeaderStatus] TO [public]
GO
GRANT INSERT ON  [dbo].[RecurringAdjustmentHeaderStatus] TO [public]
GO
GRANT SELECT ON  [dbo].[RecurringAdjustmentHeaderStatus] TO [public]
GO
GRANT UPDATE ON  [dbo].[RecurringAdjustmentHeaderStatus] TO [public]
GO
