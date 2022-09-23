CREATE TABLE [dbo].[ident_ckcnum]
(
[ckcnum] [int] NOT NULL IDENTITY(1, 1),
[id] [int] NULL,
[suser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ident_ckc__suser__23FDA6F5] DEFAULT (suser_sname()),
[sdate] [datetime] NULL CONSTRAINT [DF__ident_ckc__sdate__24F1CB2E] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ident_ckcnum] TO [public]
GO
GRANT INSERT ON  [dbo].[ident_ckcnum] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ident_ckcnum] TO [public]
GO
GRANT SELECT ON  [dbo].[ident_ckcnum] TO [public]
GO
GRANT UPDATE ON  [dbo].[ident_ckcnum] TO [public]
GO
