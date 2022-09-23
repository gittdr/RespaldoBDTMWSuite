CREATE TABLE [dbo].[tf_BoschSupplierAlias]
(
[Branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SupplierAlias] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Plant] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TMWAlias] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplierAlias2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tf_BoschSupplierAlias] ADD CONSTRAINT [PK__tf_BoschSupplier__39BC0867] PRIMARY KEY CLUSTERED ([Branch], [SupplierAlias], [Plant]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tf_BoschSupplierAlias] TO [public]
GO
GRANT INSERT ON  [dbo].[tf_BoschSupplierAlias] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tf_BoschSupplierAlias] TO [public]
GO
GRANT SELECT ON  [dbo].[tf_BoschSupplierAlias] TO [public]
GO
GRANT UPDATE ON  [dbo].[tf_BoschSupplierAlias] TO [public]
GO
