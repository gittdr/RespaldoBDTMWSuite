CREATE TABLE [dbo].[PayItemTax]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[pyt_number] [int] NOT NULL,
[tax_pyt_number] [int] NOT NULL,
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__PayItemTa__LastU__14C4B580] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__PayItemTa__LastU__15B8D9B9] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PayItemTax] ADD CONSTRAINT [pk_PayItemTax] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_PayItemTax_pyt_number] ON [dbo].[PayItemTax] ([pyt_number]) INCLUDE ([tax_pyt_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_PayItemTax_tax_pyt_number] ON [dbo].[PayItemTax] ([tax_pyt_number]) INCLUDE ([pyt_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PayItemTax] TO [public]
GO
GRANT INSERT ON  [dbo].[PayItemTax] TO [public]
GO
GRANT SELECT ON  [dbo].[PayItemTax] TO [public]
GO
GRANT UPDATE ON  [dbo].[PayItemTax] TO [public]
GO
