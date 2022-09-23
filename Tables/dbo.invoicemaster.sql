CREATE TABLE [dbo].[invoicemaster]
(
[ivm_id] [int] NOT NULL IDENTITY(1, 1),
[ivm_invoiceby] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NOT NULL,
[mov_number] [int] NOT NULL,
[ivm_invoiceordhdrnumber] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[invoicemaster] ADD CONSTRAINT [pk_ivm] PRIMARY KEY CLUSTERED ([ivm_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [uk_bymove] ON [dbo].[invoicemaster] ([ivm_invoiceby], [mov_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [uk_byorder] ON [dbo].[invoicemaster] ([ivm_invoiceby], [ord_hdrnumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[invoicemaster] TO [public]
GO
GRANT INSERT ON  [dbo].[invoicemaster] TO [public]
GO
GRANT REFERENCES ON  [dbo].[invoicemaster] TO [public]
GO
GRANT SELECT ON  [dbo].[invoicemaster] TO [public]
GO
GRANT UPDATE ON  [dbo].[invoicemaster] TO [public]
GO
