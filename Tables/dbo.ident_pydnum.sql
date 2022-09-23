CREATE TABLE [dbo].[ident_pydnum]
(
[pydnum] [int] NOT NULL IDENTITY(1, 1),
[id] [int] NULL,
[suser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ident_pyd__suser__4099E5A3] DEFAULT (suser_sname()),
[sdate] [datetime] NULL CONSTRAINT [DF__ident_pyd__sdate__418E09DC] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ident_pydnum] TO [public]
GO
GRANT INSERT ON  [dbo].[ident_pydnum] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ident_pydnum] TO [public]
GO
GRANT SELECT ON  [dbo].[ident_pydnum] TO [public]
GO
GRANT UPDATE ON  [dbo].[ident_pydnum] TO [public]
GO
