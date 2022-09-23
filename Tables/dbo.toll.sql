CREATE TABLE [dbo].[toll]
(
[toll_ident] [int] NOT NULL IDENTITY(1, 1),
[tb_ident] [int] NOT NULL,
[tb_axlecount] [int] NOT NULL,
[tb_cash_toll] [money] NOT NULL,
[tb_card_toll] [money] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[toll] ADD CONSTRAINT [pk_toll_ident] PRIMARY KEY CLUSTERED ([toll_ident]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [dk_toll_tb_ident_axlecount] ON [dbo].[toll] ([tb_ident], [tb_axlecount]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[toll] ADD CONSTRAINT [fk_toll_tollbooth_ident] FOREIGN KEY ([tb_ident]) REFERENCES [dbo].[tollbooth] ([tb_ident])
GO
GRANT DELETE ON  [dbo].[toll] TO [public]
GO
GRANT INSERT ON  [dbo].[toll] TO [public]
GO
GRANT SELECT ON  [dbo].[toll] TO [public]
GO
GRANT UPDATE ON  [dbo].[toll] TO [public]
GO
