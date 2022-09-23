CREATE TABLE [dbo].[ident_fcrnum]
(
[pyd_number] [bigint] NOT NULL IDENTITY(1, 1),
[id] [int] NULL,
[suser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ident_fcr__suser__3E723B6D] DEFAULT (suser_sname()),
[sdate] [datetime] NULL CONSTRAINT [DF__ident_fcr__sdate__3F665FA6] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ident_fcrnum] TO [public]
GO
GRANT INSERT ON  [dbo].[ident_fcrnum] TO [public]
GO
GRANT SELECT ON  [dbo].[ident_fcrnum] TO [public]
GO
GRANT UPDATE ON  [dbo].[ident_fcrnum] TO [public]
GO
