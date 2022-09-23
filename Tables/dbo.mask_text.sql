CREATE TABLE [dbo].[mask_text]
(
[english] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[language_id] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[language] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[mask_text] ADD CONSTRAINT [PK__mask_text__6D031153] PRIMARY KEY CLUSTERED ([english], [language_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[mask_text] TO [public]
GO
GRANT INSERT ON  [dbo].[mask_text] TO [public]
GO
GRANT REFERENCES ON  [dbo].[mask_text] TO [public]
GO
GRANT SELECT ON  [dbo].[mask_text] TO [public]
GO
GRANT UPDATE ON  [dbo].[mask_text] TO [public]
GO
