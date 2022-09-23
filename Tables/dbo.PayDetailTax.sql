CREATE TABLE [dbo].[PayDetailTax]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[origin_pyd_number] [int] NOT NULL,
[origin_taxable_amount] [money] NOT NULL,
[payitemtax_id] [int] NOT NULL,
[tar_number] [int] NOT NULL,
[tar_rate] [money] NOT NULL,
[effective_date] [datetime] NOT NULL,
[effective_date_source] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[generated_pyd_number] [int] NOT NULL,
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__PayDetail__LastU__2036682C] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__PayDetail__LastU__212A8C65] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PayDetailTax] ADD CONSTRAINT [pk_PayDetailTax] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_PayDetailTax_generated_pyd_number] ON [dbo].[PayDetailTax] ([generated_pyd_number]) INCLUDE ([origin_pyd_number], [origin_taxable_amount], [payitemtax_id], [tar_number], [tar_rate], [effective_date]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_PayDetailTax_origin_pyd_number] ON [dbo].[PayDetailTax] ([origin_pyd_number]) INCLUDE ([origin_taxable_amount], [payitemtax_id], [tar_number], [tar_rate], [effective_date], [generated_pyd_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_PayDetailTax_payitemtax_id] ON [dbo].[PayDetailTax] ([payitemtax_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_PayDetailTax_tar_number] ON [dbo].[PayDetailTax] ([tar_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PayDetailTax] ADD CONSTRAINT [fk_PayDetailTax_generated_pyd_number] FOREIGN KEY ([generated_pyd_number]) REFERENCES [dbo].[paydetail] ([pyd_number]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PayDetailTax] ADD CONSTRAINT [fk_PayDetailTax_origin_pyd_number] FOREIGN KEY ([origin_pyd_number]) REFERENCES [dbo].[paydetail] ([pyd_number])
GO
ALTER TABLE [dbo].[PayDetailTax] ADD CONSTRAINT [fk_PayDetailTax_payitemtax_id] FOREIGN KEY ([payitemtax_id]) REFERENCES [dbo].[PayItemTax] ([Id])
GO
GRANT DELETE ON  [dbo].[PayDetailTax] TO [public]
GO
GRANT INSERT ON  [dbo].[PayDetailTax] TO [public]
GO
GRANT SELECT ON  [dbo].[PayDetailTax] TO [public]
GO
GRANT UPDATE ON  [dbo].[PayDetailTax] TO [public]
GO
