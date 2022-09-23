CREATE TABLE [dbo].[ident_mpp_id]
(
[mpp_id] [bigint] NOT NULL IDENTITY(1, 1),
[id] [int] NULL,
[suser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ident_mpp__suser__6E99E4FA] DEFAULT (suser_sname()),
[sdate] [datetime] NULL CONSTRAINT [DF__ident_mpp__sdate__6F8E0933] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ident_mpp_id] TO [public]
GO
GRANT INSERT ON  [dbo].[ident_mpp_id] TO [public]
GO
GRANT SELECT ON  [dbo].[ident_mpp_id] TO [public]
GO
GRANT UPDATE ON  [dbo].[ident_mpp_id] TO [public]
GO
