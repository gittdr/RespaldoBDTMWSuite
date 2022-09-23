CREATE TABLE [dbo].[ident_evtnum]
(
[evtnum] [int] NOT NULL IDENTITY(1, 1),
[id] [int] NULL,
[suser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ident_evt__suser__26DA13A0] DEFAULT (suser_sname()),
[sdate] [datetime] NULL CONSTRAINT [DF__ident_evt__sdate__27CE37D9] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ident_evtnum] TO [public]
GO
GRANT INSERT ON  [dbo].[ident_evtnum] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ident_evtnum] TO [public]
GO
GRANT SELECT ON  [dbo].[ident_evtnum] TO [public]
GO
GRANT UPDATE ON  [dbo].[ident_evtnum] TO [public]
GO
