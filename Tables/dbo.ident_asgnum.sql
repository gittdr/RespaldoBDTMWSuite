CREATE TABLE [dbo].[ident_asgnum]
(
[asgnum] [int] NOT NULL IDENTITY(1, 1),
[id] [int] NULL,
[suser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ident_asg__suser__21213A4A] DEFAULT (suser_sname()),
[sdate] [datetime] NULL CONSTRAINT [DF__ident_asg__sdate__22155E83] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ident_asgnum] TO [public]
GO
GRANT INSERT ON  [dbo].[ident_asgnum] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ident_asgnum] TO [public]
GO
GRANT SELECT ON  [dbo].[ident_asgnum] TO [public]
GO
GRANT UPDATE ON  [dbo].[ident_asgnum] TO [public]
GO
