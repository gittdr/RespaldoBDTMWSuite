CREATE TABLE [dbo].[ident_notes]
(
[notes] [int] NOT NULL IDENTITY(1, 1),
[id] [int] NULL,
[suser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ident_not__suser__3AE10C4D] DEFAULT (suser_sname()),
[sdate] [datetime] NULL CONSTRAINT [DF__ident_not__sdate__3BD53086] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ident_notes] TO [public]
GO
GRANT INSERT ON  [dbo].[ident_notes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ident_notes] TO [public]
GO
GRANT SELECT ON  [dbo].[ident_notes] TO [public]
GO
GRANT UPDATE ON  [dbo].[ident_notes] TO [public]
GO
