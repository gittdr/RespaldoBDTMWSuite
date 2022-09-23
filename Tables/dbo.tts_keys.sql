CREATE TABLE [dbo].[tts_keys]
(
[kys_sort] [int] NULL,
[kys_key] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[kys_enumeration] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[kys_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tts_keys] TO [public]
GO
GRANT INSERT ON  [dbo].[tts_keys] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tts_keys] TO [public]
GO
GRANT SELECT ON  [dbo].[tts_keys] TO [public]
GO
GRANT UPDATE ON  [dbo].[tts_keys] TO [public]
GO
