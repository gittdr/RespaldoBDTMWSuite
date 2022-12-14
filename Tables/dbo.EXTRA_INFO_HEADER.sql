CREATE TABLE [dbo].[EXTRA_INFO_HEADER]
(
[EXTRA_ID] [int] NOT NULL IDENTITY(1, 1),
[TABLE_NAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[win_title] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom_command] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_EXTRA_HEADER] ON [dbo].[EXTRA_INFO_HEADER] ([EXTRA_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EXTRA_INFO_HEADER] TO [public]
GO
GRANT INSERT ON  [dbo].[EXTRA_INFO_HEADER] TO [public]
GO
GRANT REFERENCES ON  [dbo].[EXTRA_INFO_HEADER] TO [public]
GO
GRANT SELECT ON  [dbo].[EXTRA_INFO_HEADER] TO [public]
GO
GRANT UPDATE ON  [dbo].[EXTRA_INFO_HEADER] TO [public]
GO
