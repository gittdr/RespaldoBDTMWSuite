CREATE TABLE [dbo].[MasterBillTransaction]
(
[MasterBillTransactionId] [int] NOT NULL IDENTITY(1, 1),
[OriginatingMasterBillId] [int] NOT NULL,
[AppliedToMasterBillId] [int] NULL,
[TransactionMasterBillId] [int] NULL,
[TransactionSequence] [smallint] NOT NULL CONSTRAINT [DF_MasterBillTransaction_TransactionSequence] DEFAULT ((1)),
[CreatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MasterBillTransaction_CreatedBy] DEFAULT (user_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_CMasterBillTransaction_CreatedDate] DEFAULT (getdate()),
[LastUpdatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MasterBillTransaction] ADD CONSTRAINT [PK_MasterBillTransaction] PRIMARY KEY CLUSTERED ([MasterBillTransactionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MasterBillTransaction_TransactionMasterBillId] ON [dbo].[MasterBillTransaction] ([TransactionMasterBillId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MasterBillTransaction] ADD CONSTRAINT [FK_MasterBillTransaction_MasterBill_AppliedTo] FOREIGN KEY ([AppliedToMasterBillId]) REFERENCES [dbo].[MasterBill] ([MasterBillId])
GO
ALTER TABLE [dbo].[MasterBillTransaction] ADD CONSTRAINT [FK_MasterBillTransaction_MasterBill_Originating] FOREIGN KEY ([OriginatingMasterBillId]) REFERENCES [dbo].[MasterBill] ([MasterBillId])
GO
ALTER TABLE [dbo].[MasterBillTransaction] ADD CONSTRAINT [FK_MasterBillTransaction_MasterBill_Transaction] FOREIGN KEY ([TransactionMasterBillId]) REFERENCES [dbo].[MasterBill] ([MasterBillId])
GO
GRANT DELETE ON  [dbo].[MasterBillTransaction] TO [public]
GO
GRANT INSERT ON  [dbo].[MasterBillTransaction] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MasterBillTransaction] TO [public]
GO
GRANT SELECT ON  [dbo].[MasterBillTransaction] TO [public]
GO
GRANT UPDATE ON  [dbo].[MasterBillTransaction] TO [public]
GO
