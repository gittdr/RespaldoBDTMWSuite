CREATE TABLE [dbo].[RecurringAdjustmentPriority]
(
[RecurringAdjustmentPriorityId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sequence] [int] NOT NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NULL,
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RecurringAdjustmentPriority] ADD CONSTRAINT [PK_dbo.RecurringAdjustmentPriority] PRIMARY KEY CLUSTERED ([RecurringAdjustmentPriorityId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RecurringAdjustmentPriority] TO [public]
GO
GRANT INSERT ON  [dbo].[RecurringAdjustmentPriority] TO [public]
GO
GRANT SELECT ON  [dbo].[RecurringAdjustmentPriority] TO [public]
GO
GRANT UPDATE ON  [dbo].[RecurringAdjustmentPriority] TO [public]
GO
