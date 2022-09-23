CREATE TABLE [dbo].[tts_errorlog]
(
[err_batch] [int] NOT NULL,
[err_user_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_message] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_date] [datetime] NULL,
[err_number] [int] NULL,
[err_title] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_response] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_sequence] [int] NULL,
[err_icon] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_item_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_longmessage] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [err_key1] ON [dbo].[tts_errorlog] ([err_batch], [err_user_id], [err_item_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tts_errorlog_ord_hdrnumber] ON [dbo].[tts_errorlog] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tts_errorlog] TO [public]
GO
GRANT INSERT ON  [dbo].[tts_errorlog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tts_errorlog] TO [public]
GO
GRANT SELECT ON  [dbo].[tts_errorlog] TO [public]
GO
GRANT UPDATE ON  [dbo].[tts_errorlog] TO [public]
GO
