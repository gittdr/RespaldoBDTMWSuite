CREATE TABLE [dbo].[RecurringAdjustmentInterest]
(
[RecurringAdjustmentInterestTermId] [int] NOT NULL,
[Rate] [money] NOT NULL,
[RecurringAdjustmentId] [int] NOT NULL,
[pyt_number] [int] NOT NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NULL,
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedDate] [datetime] NULL,
[InterestType] [int] NULL,
[DayCountMethod] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RecurringAdjustmentInterest] ADD CONSTRAINT [PK_dbo.RecurringAdjustmentInterest] PRIMARY KEY CLUSTERED ([RecurringAdjustmentId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RecurringAdjustmentInterest] ADD CONSTRAINT [FK_dbo.RecurringAdjustmentInterest_dbo.PayType_pyt_number] FOREIGN KEY ([pyt_number]) REFERENCES [dbo].[paytype] ([pyt_number])
GO
ALTER TABLE [dbo].[RecurringAdjustmentInterest] ADD CONSTRAINT [FK_dbo.RecurringAdjustmentInterest_dbo.RecurringAdjustmentInterestTerm_RecurringAdjustmentInterestTermId] FOREIGN KEY ([RecurringAdjustmentInterestTermId]) REFERENCES [dbo].[RecurringAdjustmentInterestTerm] ([RecurringAdjustmentInterestTermId])
GO
ALTER TABLE [dbo].[RecurringAdjustmentInterest] ADD CONSTRAINT [FK_RecurringAdjustmentInterest_InterestDayCountLookup] FOREIGN KEY ([DayCountMethod]) REFERENCES [dbo].[InterestDayCountLookup] ([Id])
GO
ALTER TABLE [dbo].[RecurringAdjustmentInterest] ADD CONSTRAINT [FK_RecurringAdjustmentInterest_InterestTypeLookup] FOREIGN KEY ([InterestType]) REFERENCES [dbo].[InterestTypeLookup] ([Id])
GO
ALTER TABLE [dbo].[RecurringAdjustmentInterest] ADD CONSTRAINT [FK_RecurringAdjustmentInterest_RecurringAdjustment] FOREIGN KEY ([RecurringAdjustmentId]) REFERENCES [dbo].[RecurringAdjustment] ([RecurringAdjustmentId])
GO
GRANT DELETE ON  [dbo].[RecurringAdjustmentInterest] TO [public]
GO
GRANT INSERT ON  [dbo].[RecurringAdjustmentInterest] TO [public]
GO
GRANT SELECT ON  [dbo].[RecurringAdjustmentInterest] TO [public]
GO
GRANT UPDATE ON  [dbo].[RecurringAdjustmentInterest] TO [public]
GO
