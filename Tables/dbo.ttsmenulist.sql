CREATE TABLE [dbo].[ttsmenulist]
(
[mnu_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mnu_itemid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mnu_itemtext] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mnu_moduleid] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mnu_hotkey] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mnu_ctrl] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mnu_alt] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mnu_shift] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[kys_key] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ttsmenulist] ADD CONSTRAINT [pk_ttsmenulist] PRIMARY KEY CLUSTERED ([mnu_name], [mnu_itemid], [mnu_moduleid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ttsmenulist] TO [public]
GO
GRANT INSERT ON  [dbo].[ttsmenulist] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ttsmenulist] TO [public]
GO
GRANT SELECT ON  [dbo].[ttsmenulist] TO [public]
GO
GRANT UPDATE ON  [dbo].[ttsmenulist] TO [public]
GO
