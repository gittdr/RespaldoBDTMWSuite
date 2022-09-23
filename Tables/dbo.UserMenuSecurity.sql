CREATE TABLE [dbo].[UserMenuSecurity]
(
[ums_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ums_id_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ums_object] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ums_menukey] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ums_disableflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ums_invisibleflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ums_menucaption] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ums_custommenu_type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ums_custommenu_key] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ums_custommenu_file] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ums_custommenu_description] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ums_mergelevel] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ums_lastupdate] [datetime] NULL,
[ums_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserMenuSecurity] ADD CONSTRAINT [PK_UserMenuSecurity] PRIMARY KEY CLUSTERED ([ums_id_type], [ums_id], [ums_object], [ums_menukey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UserMenuSecurity] TO [public]
GO
GRANT INSERT ON  [dbo].[UserMenuSecurity] TO [public]
GO
GRANT REFERENCES ON  [dbo].[UserMenuSecurity] TO [public]
GO
GRANT SELECT ON  [dbo].[UserMenuSecurity] TO [public]
GO
GRANT UPDATE ON  [dbo].[UserMenuSecurity] TO [public]
GO
