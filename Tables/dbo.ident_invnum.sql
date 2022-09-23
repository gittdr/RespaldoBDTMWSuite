CREATE TABLE [dbo].[ident_invnum]
(
[invnum] [int] NOT NULL IDENTITY(1, 1),
[id] [int] NULL,
[suser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ident_inv__suser__324BC64C] DEFAULT (suser_sname()),
[sdate] [datetime] NULL CONSTRAINT [DF__ident_inv__sdate__333FEA85] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ident_invnum] TO [public]
GO
GRANT INSERT ON  [dbo].[ident_invnum] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ident_invnum] TO [public]
GO
GRANT SELECT ON  [dbo].[ident_invnum] TO [public]
GO
GRANT UPDATE ON  [dbo].[ident_invnum] TO [public]
GO
