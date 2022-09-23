CREATE TABLE [dbo].[ident_fgtnum]
(
[fgtnum] [int] NOT NULL IDENTITY(1, 1),
[id] [int] NULL,
[suser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ident_fgt__suser__29B6804B] DEFAULT (suser_sname()),
[sdate] [datetime] NULL CONSTRAINT [DF__ident_fgt__sdate__2AAAA484] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ident_fgtnum] TO [public]
GO
GRANT INSERT ON  [dbo].[ident_fgtnum] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ident_fgtnum] TO [public]
GO
GRANT SELECT ON  [dbo].[ident_fgtnum] TO [public]
GO
GRANT UPDATE ON  [dbo].[ident_fgtnum] TO [public]
GO
