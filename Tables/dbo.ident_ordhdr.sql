CREATE TABLE [dbo].[ident_ordhdr]
(
[ordhdr] [int] NOT NULL IDENTITY(1, 1),
[id] [int] NULL,
[suser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ident_ord__suser__3DBD78F8] DEFAULT (suser_sname()),
[sdate] [datetime] NULL CONSTRAINT [DF__ident_ord__sdate__3EB19D31] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ident_ordhdr] TO [public]
GO
GRANT INSERT ON  [dbo].[ident_ordhdr] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ident_ordhdr] TO [public]
GO
GRANT SELECT ON  [dbo].[ident_ordhdr] TO [public]
GO
GRANT UPDATE ON  [dbo].[ident_ordhdr] TO [public]
GO
