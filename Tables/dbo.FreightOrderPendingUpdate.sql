CREATE TABLE [dbo].[FreightOrderPendingUpdate]
(
[FreightOrderPendingUpdateId] [bigint] NOT NULL IDENTITY(1, 1),
[FreightOrderId] [bigint] NOT NULL,
[InsertDate] [datetime] NULL CONSTRAINT [DF__FreightOr__Inser__3658B0D5] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrderPendingUpdate] ADD CONSTRAINT [PK_FreightOrderPendingUpdate] PRIMARY KEY CLUSTERED ([FreightOrderPendingUpdateId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrderPendingUpdate] ADD CONSTRAINT [UK_FreightOrderPendingUpdate_FreightOrderId] UNIQUE NONCLUSTERED ([FreightOrderId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrderPendingUpdate] ADD CONSTRAINT [FK_FreightOrderPendingUpdate_FreightOrder] FOREIGN KEY ([FreightOrderId]) REFERENCES [dbo].[FreightOrder] ([FreightOrderId]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[FreightOrderPendingUpdate] TO [public]
GO
GRANT INSERT ON  [dbo].[FreightOrderPendingUpdate] TO [public]
GO
GRANT SELECT ON  [dbo].[FreightOrderPendingUpdate] TO [public]
GO
GRANT UPDATE ON  [dbo].[FreightOrderPendingUpdate] TO [public]
GO
