CREATE TABLE [dbo].[RecurringAdjustment]
(
[RecurringAdjustmentId] [int] NOT NULL IDENTITY(1, 1),
[Description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GarnishmentCapPercent] [money] NOT NULL,
[UseGrossPay] [bit] NOT NULL,
[DefaultRate] [money] NOT NULL,
[RecurringAdjustmentPriorityId] [int] NOT NULL,
[RecurringAdjustmentBasisId] [int] NOT NULL,
[RecurringAdjustmentTypeId] [int] NOT NULL,
[RecurringAdjustmentTermId] [int] NOT NULL,
[pyt_number] [int] NOT NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NULL,
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedDate] [datetime] NULL,
[QuantityCriteria] [money] NULL,
[LeftCriteria] [int] NULL,
[MileageCriteria] [int] NULL,
[SequentialFlag] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RecurringAdjustment] ADD CONSTRAINT [PK_dbo.RecurringAdjustment] PRIMARY KEY CLUSTERED ([RecurringAdjustmentId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RecurringAdjustment] ADD CONSTRAINT [FK_dbo.RecurringAdjustment_dbo.PayType_pyt_number] FOREIGN KEY ([pyt_number]) REFERENCES [dbo].[paytype] ([pyt_number])
GO
ALTER TABLE [dbo].[RecurringAdjustment] ADD CONSTRAINT [FK_dbo.RecurringAdjustment_dbo.RecurringAdjustmentBasis_RecurringAdjustmentTermId] FOREIGN KEY ([RecurringAdjustmentBasisId]) REFERENCES [dbo].[RecurringAdjustmentBasis] ([RecurringAdjustmentBasisId])
GO
ALTER TABLE [dbo].[RecurringAdjustment] ADD CONSTRAINT [FK_dbo.RecurringAdjustment_dbo.RecurringAdjustmentPriority_RecurringAdjustmentPriorityId] FOREIGN KEY ([RecurringAdjustmentPriorityId]) REFERENCES [dbo].[RecurringAdjustmentPriority] ([RecurringAdjustmentPriorityId])
GO
ALTER TABLE [dbo].[RecurringAdjustment] ADD CONSTRAINT [FK_dbo.RecurringAdjustment_dbo.RecurringAdjustmentTerm_RecurringAdjustmentTermId] FOREIGN KEY ([RecurringAdjustmentTermId]) REFERENCES [dbo].[RecurringAdjustmentTerm] ([RecurringAdjustmentTermId])
GO
ALTER TABLE [dbo].[RecurringAdjustment] ADD CONSTRAINT [FK_dbo.RecurringAdjustment_dbo.RecurringAdjustmentType_RecurringAdjustmentTypeId] FOREIGN KEY ([RecurringAdjustmentTypeId]) REFERENCES [dbo].[RecurringAdjustmentType] ([RecurringAdjustmentTypeId])
GO
ALTER TABLE [dbo].[RecurringAdjustment] ADD CONSTRAINT [FK_RecurringAdjustment_RecurringAdjustmentLeftCriteria] FOREIGN KEY ([LeftCriteria]) REFERENCES [dbo].[RecurringAdjustmentLeftCriteria] ([ID])
GO
ALTER TABLE [dbo].[RecurringAdjustment] ADD CONSTRAINT [FK_RecurringAdjustment_RecurringAdjustmentMileageCriteria] FOREIGN KEY ([MileageCriteria]) REFERENCES [dbo].[RecurringAdjustmentMileageCriteria] ([ID])
GO
GRANT DELETE ON  [dbo].[RecurringAdjustment] TO [public]
GO
GRANT INSERT ON  [dbo].[RecurringAdjustment] TO [public]
GO
GRANT SELECT ON  [dbo].[RecurringAdjustment] TO [public]
GO
GRANT UPDATE ON  [dbo].[RecurringAdjustment] TO [public]
GO
