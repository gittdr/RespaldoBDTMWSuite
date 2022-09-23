CREATE TABLE [dbo].[DedicatedRevenueAllocation]
(
[DedicatedRevenueAllocationId] [int] NOT NULL IDENTITY(1, 1),
[DedicatedBillId] [int] NOT NULL,
[DedicatedDetailId] [int] NULL,
[DedicatedRevenueAllocationTypeId] [int] NOT NULL,
[Amount] [decimal] (19, 4) NULL,
[DebitAmount] [decimal] (19, 4) NULL,
[CreditAmount] [decimal] (19, 4) NULL,
[GlNumber] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GlNumberIndex] [int] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_DedicatedRevenueAllocation_CreatedDate] DEFAULT (getdate()),
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DedicatedRevenueAllocation_CreatedBy] DEFAULT (user_name()),
[LastUpdatedDate] [datetime] NOT NULL,
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedRevenueAllocation] ADD CONSTRAINT [PK_DedicatedRevenueAllocation] PRIMARY KEY CLUSTERED ([DedicatedRevenueAllocationId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DedicatedRevenueAllocation_DedicatedBillId] ON [dbo].[DedicatedRevenueAllocation] ([DedicatedBillId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DedicatedRevenueAllocation_DedicatedDetailId] ON [dbo].[DedicatedRevenueAllocation] ([DedicatedDetailId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedRevenueAllocation] ADD CONSTRAINT [FK_DedicatedRevenueAllocation_DedicatedBill] FOREIGN KEY ([DedicatedBillId]) REFERENCES [dbo].[DedicatedBill] ([DedicatedBillId])
GO
ALTER TABLE [dbo].[DedicatedRevenueAllocation] ADD CONSTRAINT [FK_DedicatedRevenueAllocation_DedicatedDetail] FOREIGN KEY ([DedicatedDetailId]) REFERENCES [dbo].[DedicatedDetail] ([DedicatedDetailId])
GO
ALTER TABLE [dbo].[DedicatedRevenueAllocation] ADD CONSTRAINT [FK_DedicatedRevenueAllocation_DedicatedRevenueAllocationType] FOREIGN KEY ([DedicatedRevenueAllocationTypeId]) REFERENCES [dbo].[DedicatedRevenueAllocationType] ([DedicatedRevenueAllocationTypeId])
GO
GRANT DELETE ON  [dbo].[DedicatedRevenueAllocation] TO [public]
GO
GRANT INSERT ON  [dbo].[DedicatedRevenueAllocation] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DedicatedRevenueAllocation] TO [public]
GO
GRANT SELECT ON  [dbo].[DedicatedRevenueAllocation] TO [public]
GO
GRANT UPDATE ON  [dbo].[DedicatedRevenueAllocation] TO [public]
GO
