CREATE TABLE [dbo].[LoadViewXT_userobject]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[object] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[user_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[view_type] [smallint] NOT NULL,
[dwsyntax] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_type1] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[view_versiondate] [datetime] NULL,
[original_dwsyntax] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[default_view] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[language_id] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zoom] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LoadViewXT_userobject] ADD CONSTRAINT [pk_LoadViewXT_userobject] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[LoadViewXT_userobject] TO [public]
GO
GRANT INSERT ON  [dbo].[LoadViewXT_userobject] TO [public]
GO
GRANT REFERENCES ON  [dbo].[LoadViewXT_userobject] TO [public]
GO
GRANT SELECT ON  [dbo].[LoadViewXT_userobject] TO [public]
GO
GRANT UPDATE ON  [dbo].[LoadViewXT_userobject] TO [public]
GO
