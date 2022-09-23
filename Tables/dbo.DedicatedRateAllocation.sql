CREATE TABLE [dbo].[DedicatedRateAllocation]
(
[DedicatedRateAllocationId] [int] NOT NULL IDENTITY(1, 1),
[DedicatedBillId] [int] NOT NULL,
[DedicatedDetailId] [int] NOT NULL,
[ivd_number] [int] NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_DedicatedRateAllocation_CreatedDate] DEFAULT (getdate()),
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DedicatedRateAllocation_CreatedBy] DEFAULT (user_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedRateAllocation] ADD CONSTRAINT [PK_DedicatedRateAllocation] PRIMARY KEY CLUSTERED ([DedicatedRateAllocationId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedRateAllocation] ADD CONSTRAINT [FK_DedicatedRateAllocation_DedicatedBill] FOREIGN KEY ([DedicatedBillId]) REFERENCES [dbo].[DedicatedBill] ([DedicatedBillId])
GO
ALTER TABLE [dbo].[DedicatedRateAllocation] ADD CONSTRAINT [FK_DedicatedRateAllocation_DedicatedDetail] FOREIGN KEY ([DedicatedDetailId]) REFERENCES [dbo].[DedicatedDetail] ([DedicatedDetailId])
GO
ALTER TABLE [dbo].[DedicatedRateAllocation] ADD CONSTRAINT [FK_DedicatedRateAllocation_invoicedetail] FOREIGN KEY ([ivd_number]) REFERENCES [dbo].[invoicedetail] ([ivd_number])
GO
GRANT DELETE ON  [dbo].[DedicatedRateAllocation] TO [public]
GO
GRANT INSERT ON  [dbo].[DedicatedRateAllocation] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DedicatedRateAllocation] TO [public]
GO
GRANT SELECT ON  [dbo].[DedicatedRateAllocation] TO [public]
GO
GRANT UPDATE ON  [dbo].[DedicatedRateAllocation] TO [public]
GO
