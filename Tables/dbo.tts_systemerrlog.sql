CREATE TABLE [dbo].[tts_systemerrlog]
(
[sel_user_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sel_date] [datetime] NOT NULL,
[sel_id] [int] NOT NULL,
[sel_app] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sel_window] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sel_object] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sel_script] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sel_number] [int] NULL,
[sel_line] [int] NULL,
[sel_text] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sel_response] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sel_appversion] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tts_systemerrlog] TO [public]
GO
GRANT INSERT ON  [dbo].[tts_systemerrlog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tts_systemerrlog] TO [public]
GO
GRANT SELECT ON  [dbo].[tts_systemerrlog] TO [public]
GO
GRANT UPDATE ON  [dbo].[tts_systemerrlog] TO [public]
GO
