CREATE TABLE [dbo].[InvoiceDetailTPLCostXRef]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ivd_number] [int] NOT NULL,
[costId] [int] NOT NULL,
[costIdType] [int] NOT NULL,
[createddate] [datetime2] (3) NULL CONSTRAINT [DF__InvoiceDe__creat__43702102] DEFAULT (getdate()),
[createdby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__InvoiceDe__creat__4464453B] DEFAULT (user_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InvoiceDetailTPLCostXRef] ADD CONSTRAINT [PK_InvoiceDetailTPLCostXRef] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InvoiceDetailTPLCostXRef] ADD CONSTRAINT [UK_InvoiceDetailTPLCostXRef] UNIQUE NONCLUSTERED ([ivd_number], [costId], [costIdType]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[InvoiceDetailTPLCostXRef] TO [public]
GO
GRANT INSERT ON  [dbo].[InvoiceDetailTPLCostXRef] TO [public]
GO
GRANT REFERENCES ON  [dbo].[InvoiceDetailTPLCostXRef] TO [public]
GO
GRANT SELECT ON  [dbo].[InvoiceDetailTPLCostXRef] TO [public]
GO
GRANT UPDATE ON  [dbo].[InvoiceDetailTPLCostXRef] TO [public]
GO
