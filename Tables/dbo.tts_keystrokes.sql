CREATE TABLE [dbo].[tts_keystrokes]
(
[kys_keystroke] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[kys_date] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tts_keystrokes] TO [public]
GO
GRANT INSERT ON  [dbo].[tts_keystrokes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tts_keystrokes] TO [public]
GO
GRANT SELECT ON  [dbo].[tts_keystrokes] TO [public]
GO
GRANT UPDATE ON  [dbo].[tts_keystrokes] TO [public]
GO
