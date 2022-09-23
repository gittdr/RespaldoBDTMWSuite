CREATE TABLE [dbo].[cdfuelproducts]
(
[cfp_identity] [int] NOT NULL IDENTITY(1, 1),
[cfb_xfacetype] [int] NOT NULL,
[cfp_productcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cfp_description] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cfp_fueltype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfp_exportfuel] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfp_create_fuelpurchase] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdfuelproducts] ADD CONSTRAINT [uk_cdfuelproducts_cfp_identity] PRIMARY KEY CLUSTERED ([cfp_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_cdfp_factetype_prodcode] ON [dbo].[cdfuelproducts] ([cfb_xfacetype], [cfp_productcode]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdfuelproducts] ADD CONSTRAINT [fk_cdfuelproductstoheader] FOREIGN KEY ([cfb_xfacetype]) REFERENCES [dbo].[cdfuelbill_header] ([cfb_xfacetype])
GO
GRANT DELETE ON  [dbo].[cdfuelproducts] TO [public]
GO
GRANT INSERT ON  [dbo].[cdfuelproducts] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdfuelproducts] TO [public]
GO
GRANT SELECT ON  [dbo].[cdfuelproducts] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdfuelproducts] TO [public]
GO
