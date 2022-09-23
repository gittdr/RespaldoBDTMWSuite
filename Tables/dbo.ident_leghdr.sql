CREATE TABLE [dbo].[ident_leghdr]
(
[leghdr] [int] NOT NULL IDENTITY(1, 1),
[id] [int] NULL,
[suser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ident_leg__suser__352832F7] DEFAULT (suser_sname()),
[sdate] [datetime] NULL CONSTRAINT [DF__ident_leg__sdate__361C5730] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ident_leghdr] TO [public]
GO
GRANT INSERT ON  [dbo].[ident_leghdr] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ident_leghdr] TO [public]
GO
GRANT SELECT ON  [dbo].[ident_leghdr] TO [public]
GO
GRANT UPDATE ON  [dbo].[ident_leghdr] TO [public]
GO
