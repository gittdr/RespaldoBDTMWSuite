CREATE TABLE [dbo].[ImageInvoiceRecs]
(
[iir_ID] [int] NOT NULL IDENTITY(1, 1),
[image] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImageInvoiceRecs] ADD CONSTRAINT [PK__ImageInvoiceRecs__6D63CF5D] PRIMARY KEY CLUSTERED ([iir_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ImageInvoiceRecs] TO [public]
GO
GRANT INSERT ON  [dbo].[ImageInvoiceRecs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ImageInvoiceRecs] TO [public]
GO
GRANT SELECT ON  [dbo].[ImageInvoiceRecs] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImageInvoiceRecs] TO [public]
GO
