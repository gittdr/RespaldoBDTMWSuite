CREATE TABLE [dbo].[ident_ltldelv]
(
[ltldelv] [int] NOT NULL IDENTITY(1, 1),
[id] [int] NULL,
[suser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ident_ltl__suser__208B6DE7] DEFAULT (suser_sname()),
[sdate] [datetime] NULL CONSTRAINT [DF__ident_ltl__sdate__217F9220] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ident_ltldelv] TO [public]
GO
GRANT INSERT ON  [dbo].[ident_ltldelv] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ident_ltldelv] TO [public]
GO
GRANT SELECT ON  [dbo].[ident_ltldelv] TO [public]
GO
GRANT UPDATE ON  [dbo].[ident_ltldelv] TO [public]
GO
