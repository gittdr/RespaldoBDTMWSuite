CREATE TABLE [dbo].[invoiceheader_misc]
(
[ihm_invoicenumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ihm_hdrnumber] [int] NOT NULL,
[ihm_definition] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ihm_misc_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[invoiceheader_misc] ADD CONSTRAINT [pk_ihm_number] PRIMARY KEY CLUSTERED ([ihm_hdrnumber]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_ihm_invoicenumber] ON [dbo].[invoiceheader_misc] ([ihm_invoicenumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[invoiceheader_misc] TO [public]
GO
GRANT INSERT ON  [dbo].[invoiceheader_misc] TO [public]
GO
GRANT REFERENCES ON  [dbo].[invoiceheader_misc] TO [public]
GO
GRANT SELECT ON  [dbo].[invoiceheader_misc] TO [public]
GO
GRANT UPDATE ON  [dbo].[invoiceheader_misc] TO [public]
GO
