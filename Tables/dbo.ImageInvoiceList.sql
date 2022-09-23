CREATE TABLE [dbo].[ImageInvoiceList]
(
[iil_ID] [int] NOT NULL IDENTITY(1, 1),
[ivh_hdrnumber] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImageInvoiceList] ADD CONSTRAINT [PK__ImageInvoiceList__65C2AD95] PRIMARY KEY CLUSTERED ([iil_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ivhhdrnumber] ON [dbo].[ImageInvoiceList] ([ivh_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ImageInvoiceList] TO [public]
GO
GRANT INSERT ON  [dbo].[ImageInvoiceList] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ImageInvoiceList] TO [public]
GO
GRANT SELECT ON  [dbo].[ImageInvoiceList] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImageInvoiceList] TO [public]
GO
