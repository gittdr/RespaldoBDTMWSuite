CREATE TABLE [dbo].[tollroute_booth_mapping]
(
[trbm_ident] [int] NOT NULL IDENTITY(1, 1),
[tr_ident] [int] NOT NULL,
[tb_ident] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tollroute_booth_mapping] ADD CONSTRAINT [pk_trbm_ident] PRIMARY KEY CLUSTERED ([trbm_ident]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [dk_trbm_tr_tb_ident] ON [dbo].[tollroute_booth_mapping] ([tr_ident], [tb_ident]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tollroute_booth_mapping] ADD CONSTRAINT [fk_trbm_tollbooth_ident] FOREIGN KEY ([tb_ident]) REFERENCES [dbo].[tollbooth] ([tb_ident])
GO
ALTER TABLE [dbo].[tollroute_booth_mapping] ADD CONSTRAINT [fk_trbm_tollroute_ident] FOREIGN KEY ([tr_ident]) REFERENCES [dbo].[toll_route] ([tr_ident])
GO
GRANT DELETE ON  [dbo].[tollroute_booth_mapping] TO [public]
GO
GRANT INSERT ON  [dbo].[tollroute_booth_mapping] TO [public]
GO
GRANT SELECT ON  [dbo].[tollroute_booth_mapping] TO [public]
GO
GRANT UPDATE ON  [dbo].[tollroute_booth_mapping] TO [public]
GO
