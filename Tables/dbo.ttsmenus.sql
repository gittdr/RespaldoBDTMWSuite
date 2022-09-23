CREATE TABLE [dbo].[ttsmenus]
(
[app_id] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[menu_id] [int] NOT NULL,
[menu_name] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[window_name] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[window_size] [tinyint] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ttsmenus] TO [public]
GO
GRANT INSERT ON  [dbo].[ttsmenus] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ttsmenus] TO [public]
GO
GRANT SELECT ON  [dbo].[ttsmenus] TO [public]
GO
GRANT UPDATE ON  [dbo].[ttsmenus] TO [public]
GO
