CREATE TABLE [dbo].[ident_movnum]
(
[movnum] [int] NOT NULL IDENTITY(1, 1),
[id] [int] NULL,
[suser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ident_mov__suser__38049FA2] DEFAULT (suser_sname()),
[sdate] [datetime] NULL CONSTRAINT [DF__ident_mov__sdate__38F8C3DB] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ident_movnum] TO [public]
GO
GRANT INSERT ON  [dbo].[ident_movnum] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ident_movnum] TO [public]
GO
GRANT SELECT ON  [dbo].[ident_movnum] TO [public]
GO
GRANT UPDATE ON  [dbo].[ident_movnum] TO [public]
GO
