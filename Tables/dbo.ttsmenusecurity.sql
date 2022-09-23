CREATE TABLE [dbo].[ttsmenusecurity]
(
[mnu_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mnu_itemid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mnu_useridtype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mnu_userid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mnu_accesslevel] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ttsmenusecurity] ADD CONSTRAINT [pk_ttsmenusecurity] PRIMARY KEY CLUSTERED ([mnu_name], [mnu_itemid], [mnu_useridtype], [mnu_userid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ttsmenusecurity] ON [dbo].[ttsmenusecurity] ([mnu_useridtype], [mnu_userid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ttsmenusecurity] TO [public]
GO
GRANT INSERT ON  [dbo].[ttsmenusecurity] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ttsmenusecurity] TO [public]
GO
GRANT SELECT ON  [dbo].[ttsmenusecurity] TO [public]
GO
GRANT UPDATE ON  [dbo].[ttsmenusecurity] TO [public]
GO
