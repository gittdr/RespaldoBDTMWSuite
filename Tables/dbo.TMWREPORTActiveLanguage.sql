CREATE TABLE [dbo].[TMWREPORTActiveLanguage]
(
[language] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMWREPORTActiveLanguage] ADD CONSTRAINT [PK__TMWREPOR__EFADA5D8F22CB699] PRIMARY KEY CLUSTERED ([language]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMWREPORTActiveLanguage] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWREPORTActiveLanguage] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMWREPORTActiveLanguage] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWREPORTActiveLanguage] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWREPORTActiveLanguage] TO [public]
GO
