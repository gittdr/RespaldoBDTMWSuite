CREATE TABLE [dbo].[ident_ltlpick]
(
[ltlpick] [int] NOT NULL IDENTITY(1, 1),
[id] [int] NULL,
[suser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ident_ltl__suser__17F627E6] DEFAULT (suser_sname()),
[sdate] [datetime] NULL CONSTRAINT [DF__ident_ltl__sdate__18EA4C1F] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ident_ltlpick] TO [public]
GO
GRANT INSERT ON  [dbo].[ident_ltlpick] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ident_ltlpick] TO [public]
GO
GRANT SELECT ON  [dbo].[ident_ltlpick] TO [public]
GO
GRANT UPDATE ON  [dbo].[ident_ltlpick] TO [public]
GO
