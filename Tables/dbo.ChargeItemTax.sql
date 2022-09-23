CREATE TABLE [dbo].[ChargeItemTax]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[cht_number] [int] NOT NULL,
[tax_cht_number] [int] NOT NULL,
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__ChargeIte__LastU__10F4249C] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__ChargeIte__LastU__11E848D5] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChargeItemTax] ADD CONSTRAINT [pk_ChargeItemTax] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ChargeItemTax_cht_number] ON [dbo].[ChargeItemTax] ([cht_number]) INCLUDE ([tax_cht_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ChargeItemTax_tax_cht_number] ON [dbo].[ChargeItemTax] ([tax_cht_number]) INCLUDE ([cht_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ChargeItemTax] TO [public]
GO
GRANT INSERT ON  [dbo].[ChargeItemTax] TO [public]
GO
GRANT SELECT ON  [dbo].[ChargeItemTax] TO [public]
GO
GRANT UPDATE ON  [dbo].[ChargeItemTax] TO [public]
GO
