CREATE TABLE [dbo].[DedicatedTransaction]
(
[DedicatedTransactionId] [int] NOT NULL IDENTITY(1, 1),
[DedicatedMasterId] [int] NOT NULL,
[AppliesToDedicatedBillId] [int] NULL,
[TransactionDedicatedBillId] [int] NULL,
[SequenceNumber] [smallint] NOT NULL CONSTRAINT [DF_DedicatedTransaction_SequenceNumber] DEFAULT ((1)),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_DedicatedTransaction_CreatedDate] DEFAULT (getdate()),
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DedicatedTransaction_CreatedBy] DEFAULT (user_name()),
[LastUpdatedDate] [datetime] NULL,
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedTransaction] ADD CONSTRAINT [PK_DedicatedTransaction] PRIMARY KEY CLUSTERED ([DedicatedTransactionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DedicatedTransaction_DedicatedMasterId] ON [dbo].[DedicatedTransaction] ([DedicatedMasterId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DedicatedTransaction_TransactionDedicatedBillId] ON [dbo].[DedicatedTransaction] ([TransactionDedicatedBillId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedTransaction] ADD CONSTRAINT [FK_DedicatedTransaction_DedicatedBill_AppliesTo] FOREIGN KEY ([AppliesToDedicatedBillId]) REFERENCES [dbo].[DedicatedBill] ([DedicatedBillId])
GO
ALTER TABLE [dbo].[DedicatedTransaction] ADD CONSTRAINT [FK_DedicatedTransaction_DedicatedBill_Transaction] FOREIGN KEY ([TransactionDedicatedBillId]) REFERENCES [dbo].[DedicatedBill] ([DedicatedBillId])
GO
ALTER TABLE [dbo].[DedicatedTransaction] ADD CONSTRAINT [FK_DedicatedTransaction_DedicatedMaster] FOREIGN KEY ([DedicatedMasterId]) REFERENCES [dbo].[DedicatedMaster] ([DedicatedMasterId])
GO
GRANT DELETE ON  [dbo].[DedicatedTransaction] TO [public]
GO
GRANT INSERT ON  [dbo].[DedicatedTransaction] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DedicatedTransaction] TO [public]
GO
GRANT SELECT ON  [dbo].[DedicatedTransaction] TO [public]
GO
GRANT UPDATE ON  [dbo].[DedicatedTransaction] TO [public]
GO
