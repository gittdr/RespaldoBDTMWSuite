CREATE TABLE [dbo].[ident_stpnum]
(
[stpnum] [int] NOT NULL IDENTITY(1, 1),
[id] [int] NULL,
[suser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ident_stp__suser__4376524E] DEFAULT (suser_sname()),
[sdate] [datetime] NULL CONSTRAINT [DF__ident_stp__sdate__446A7687] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ident_stpnum] TO [public]
GO
GRANT INSERT ON  [dbo].[ident_stpnum] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ident_stpnum] TO [public]
GO
GRANT SELECT ON  [dbo].[ident_stpnum] TO [public]
GO
GRANT UPDATE ON  [dbo].[ident_stpnum] TO [public]
GO
