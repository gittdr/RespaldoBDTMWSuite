CREATE TABLE [dbo].[ident_invdet]
(
[invdet] [int] NOT NULL IDENTITY(1, 1),
[id] [int] NULL,
[suser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ident_inv__suser__2C92ECF6] DEFAULT (suser_sname()),
[sdate] [datetime] NULL CONSTRAINT [DF__ident_inv__sdate__2D87112F] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ident_invdet] TO [public]
GO
GRANT INSERT ON  [dbo].[ident_invdet] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ident_invdet] TO [public]
GO
GRANT SELECT ON  [dbo].[ident_invdet] TO [public]
GO
GRANT UPDATE ON  [dbo].[ident_invdet] TO [public]
GO
