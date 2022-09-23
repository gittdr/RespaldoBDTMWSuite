CREATE TABLE [dbo].[RecurringAdjustmentDetail]
(
[RecurringAdjustmentDetailId] [int] NOT NULL IDENTITY(1, 1),
[Amount] [money] NOT NULL,
[AdustmentDate] [datetime] NOT NULL,
[RecurringAdjustmentHeaderId] [int] NOT NULL,
[RecurringAdjustmentDetailTypeId] [int] NOT NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NULL,
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedDate] [datetime] NULL,
[AppliesTo] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RecurringAdjustmentDetail] ADD CONSTRAINT [PK_dbo.RecurringAdjustmentDetail] PRIMARY KEY CLUSTERED ([RecurringAdjustmentDetailId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RecurringAdjustmentDetail] ADD CONSTRAINT [FK_dbo.RecurringAdjustmentDetail_dbo.RecurringAdjustmentDetailType_RecurringAdjustmentDetailTypeId] FOREIGN KEY ([RecurringAdjustmentDetailTypeId]) REFERENCES [dbo].[RecurringAdjustmentDetailType] ([RecurringAdjustmentDetailTypeId])
GO
ALTER TABLE [dbo].[RecurringAdjustmentDetail] ADD CONSTRAINT [FK_dbo.RecurringAdjustmentDetail_dbo.RecurringAdjustmentHeader_RecurringAdjustmentHeaderId] FOREIGN KEY ([RecurringAdjustmentHeaderId]) REFERENCES [dbo].[RecurringAdjustmentHeader] ([RecurringAdjustmentHeaderId])
GO
GRANT DELETE ON  [dbo].[RecurringAdjustmentDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[RecurringAdjustmentDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[RecurringAdjustmentDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[RecurringAdjustmentDetail] TO [public]
GO
