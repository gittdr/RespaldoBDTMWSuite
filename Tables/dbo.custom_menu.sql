CREATE TABLE [dbo].[custom_menu]
(
[cm_id] [int] NOT NULL,
[cm_position] [int] NOT NULL,
[cm_description] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cm_menutext] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cm_type] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cm_key] [char] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cm_file] [char] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cm_parm] [char] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cm_app] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cm_webpage_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cm_user_opt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cm_sequence] [int] NULL,
[cm_menutext_hidden] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cm_menuicon_hidden] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[custom_menu] TO [public]
GO
GRANT INSERT ON  [dbo].[custom_menu] TO [public]
GO
GRANT REFERENCES ON  [dbo].[custom_menu] TO [public]
GO
GRANT SELECT ON  [dbo].[custom_menu] TO [public]
GO
GRANT UPDATE ON  [dbo].[custom_menu] TO [public]
GO
