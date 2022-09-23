CREATE TABLE [dbo].[RecurringAdjustmentHeader]
(
[RecurringAdjustmentHeaderId] [int] NOT NULL IDENTITY(1, 1),
[MaxAmount] [money] NOT NULL,
[Rate] [money] NOT NULL,
[IssuedDate] [datetime] NOT NULL,
[VendorId] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferenceNumberType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferenceNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PurchaseDate] [datetime] NOT NULL,
[PurchaseLocation] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecurringAdjustmentId] [int] NOT NULL,
[AssignmentType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AssignmentId] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecurringAdjustmentHeaderStatusId] [int] NOT NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NULL,
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedDate] [datetime] NULL,
[PaymentFreq] [int] NULL,
[LoanDurationYrs] [float] NULL,
[PayToApplyPerResource] [bit] NULL,
[PayToApplyWhenInactive] [bit] NULL,
[RowVersion] [timestamp] NOT NULL,
[ReopenDate] [datetime] NULL,
[RecurringAdjustmentPriorityId] [int] NULL,
[SequentialFlag] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RecurringAdjustmentHeader] ADD CONSTRAINT [PK_dbo.RecurringAdjustmentHeader] PRIMARY KEY CLUSTERED ([RecurringAdjustmentHeaderId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RecurringAdjustmentHeader] ADD CONSTRAINT [FK_dbo.RecurringAdjustmentHeader_dbo.RecurringAdjustment_RecurringAdjustmentId] FOREIGN KEY ([RecurringAdjustmentId]) REFERENCES [dbo].[RecurringAdjustment] ([RecurringAdjustmentId])
GO
ALTER TABLE [dbo].[RecurringAdjustmentHeader] ADD CONSTRAINT [FK_dbo.RecurringAdjustmentHeader_dbo.RecurringAdjustmentHeaderStatus_RecurringAdjustmentHeaderStatusId] FOREIGN KEY ([RecurringAdjustmentHeaderStatusId]) REFERENCES [dbo].[RecurringAdjustmentHeaderStatus] ([RecurringAdjustmentHeaderStatusId])
GO
ALTER TABLE [dbo].[RecurringAdjustmentHeader] ADD CONSTRAINT [FK_RecurringAdjustmentHeader_LoanPaymentFrequencyLookup] FOREIGN KEY ([PaymentFreq]) REFERENCES [dbo].[LoanPaymentFrequencyLookup] ([Id])
GO
GRANT DELETE ON  [dbo].[RecurringAdjustmentHeader] TO [public]
GO
GRANT INSERT ON  [dbo].[RecurringAdjustmentHeader] TO [public]
GO
GRANT SELECT ON  [dbo].[RecurringAdjustmentHeader] TO [public]
GO
GRANT UPDATE ON  [dbo].[RecurringAdjustmentHeader] TO [public]
GO
