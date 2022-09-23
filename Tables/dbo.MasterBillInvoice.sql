CREATE TABLE [dbo].[MasterBillInvoice]
(
[MasterBillId] [int] NOT NULL,
[ivh_hdrnumber] [int] NOT NULL,
[CreatedBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MasterBil__Creat__23C3D492] DEFAULT (suser_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__MasterBil__Creat__24B7F8CB] DEFAULT (getdate()),
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__MasterBil__LastU__25AC1D04] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MasterBil__LastU__26A0413D] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MasterBillInvoice] ADD CONSTRAINT [PK_dbo.MasterBillInvoice] PRIMARY KEY CLUSTERED ([ivh_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ivh_hdrnumber] ON [dbo].[MasterBillInvoice] ([ivh_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MasterBillId] ON [dbo].[MasterBillInvoice] ([MasterBillId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MasterBillInvoice] ADD CONSTRAINT [FK_dbo.MasterBillInvoice_dbo.InvoiceHeader_ivh_hdrnumber] FOREIGN KEY ([ivh_hdrnumber]) REFERENCES [dbo].[invoiceheader] ([ivh_hdrnumber])
GO
ALTER TABLE [dbo].[MasterBillInvoice] ADD CONSTRAINT [FK_dbo.MasterBillInvoice_dbo.MasterBill_MasterBillId] FOREIGN KEY ([MasterBillId]) REFERENCES [dbo].[MasterBill] ([MasterBillId])
GO
GRANT DELETE ON  [dbo].[MasterBillInvoice] TO [public]
GO
GRANT INSERT ON  [dbo].[MasterBillInvoice] TO [public]
GO
GRANT SELECT ON  [dbo].[MasterBillInvoice] TO [public]
GO
GRANT UPDATE ON  [dbo].[MasterBillInvoice] TO [public]
GO
