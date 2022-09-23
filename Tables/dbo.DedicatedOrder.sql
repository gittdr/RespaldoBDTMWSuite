CREATE TABLE [dbo].[DedicatedOrder]
(
[DedicatedOrderId] [int] NOT NULL IDENTITY(1, 1),
[DedicatedBillId] [int] NOT NULL,
[OrderId] [int] NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_DedicatedOrder_CreatedDate] DEFAULT (getdate()),
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DedicatedOrder_CreatedBy] DEFAULT (user_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedOrder] ADD CONSTRAINT [PK_DedicatedOrder] PRIMARY KEY CLUSTERED ([DedicatedOrderId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DedicatedOrder_DedicatedBillId] ON [dbo].[DedicatedOrder] ([DedicatedBillId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedOrder] ADD CONSTRAINT [FK_DedicatedOrder_DedicatedBill] FOREIGN KEY ([DedicatedBillId]) REFERENCES [dbo].[DedicatedBill] ([DedicatedBillId])
GO
GRANT DELETE ON  [dbo].[DedicatedOrder] TO [public]
GO
GRANT INSERT ON  [dbo].[DedicatedOrder] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DedicatedOrder] TO [public]
GO
GRANT SELECT ON  [dbo].[DedicatedOrder] TO [public]
GO
GRANT UPDATE ON  [dbo].[DedicatedOrder] TO [public]
GO
