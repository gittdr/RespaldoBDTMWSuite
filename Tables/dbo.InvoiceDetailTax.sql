CREATE TABLE [dbo].[InvoiceDetailTax]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[origin_ivd_number] [int] NOT NULL,
[origin_fgt_number] [int] NULL,
[origin_taxable_amount] [money] NOT NULL,
[chargeitemtax_id] [int] NOT NULL,
[tar_number] [int] NOT NULL,
[tar_rate] [money] NOT NULL,
[effective_date] [datetime] NOT NULL,
[effective_date_source] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[generated_ivd_number] [int] NOT NULL,
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__InvoiceDe__LastU__18954664] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__InvoiceDe__LastU__19896A9D] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InvoiceDetailTax] ADD CONSTRAINT [pk_InvoiceDetailTax] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_InvoiceDetailTax_chargeitemtax_id] ON [dbo].[InvoiceDetailTax] ([chargeitemtax_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_InvoiceDetailTax_generated_ivd_number] ON [dbo].[InvoiceDetailTax] ([generated_ivd_number]) INCLUDE ([origin_ivd_number], [origin_fgt_number], [origin_taxable_amount], [chargeitemtax_id], [tar_number], [tar_rate], [effective_date]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_InvoiceDetailTax_origin_ivd_number] ON [dbo].[InvoiceDetailTax] ([origin_ivd_number]) INCLUDE ([origin_fgt_number], [origin_taxable_amount], [chargeitemtax_id], [tar_number], [tar_rate], [effective_date], [generated_ivd_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_InvoiceDetailTax_tar_number] ON [dbo].[InvoiceDetailTax] ([tar_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InvoiceDetailTax] ADD CONSTRAINT [fk_InvoiceDetailTax_chargeitemtax_id] FOREIGN KEY ([chargeitemtax_id]) REFERENCES [dbo].[ChargeItemTax] ([Id])
GO
ALTER TABLE [dbo].[InvoiceDetailTax] ADD CONSTRAINT [fk_InvoiceDetailTax_generated_ivd_number] FOREIGN KEY ([generated_ivd_number]) REFERENCES [dbo].[invoicedetail] ([ivd_number]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceDetailTax] ADD CONSTRAINT [fk_InvoiceDetailTax_origin_ivd_number] FOREIGN KEY ([origin_ivd_number]) REFERENCES [dbo].[invoicedetail] ([ivd_number])
GO
ALTER TABLE [dbo].[InvoiceDetailTax] ADD CONSTRAINT [fk_InvoiceDetailTax_tar_number] FOREIGN KEY ([tar_number]) REFERENCES [dbo].[tariffheader] ([tar_number])
GO
GRANT DELETE ON  [dbo].[InvoiceDetailTax] TO [public]
GO
GRANT INSERT ON  [dbo].[InvoiceDetailTax] TO [public]
GO
GRANT SELECT ON  [dbo].[InvoiceDetailTax] TO [public]
GO
GRANT UPDATE ON  [dbo].[InvoiceDetailTax] TO [public]
GO
