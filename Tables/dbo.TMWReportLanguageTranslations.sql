CREATE TABLE [dbo].[TMWReportLanguageTranslations]
(
[code_key] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[language] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tmwtranslation] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMWReportLanguageTranslations] ADD CONSTRAINT [PK_TMWReportLanguageTranslations] PRIMARY KEY CLUSTERED ([code_key], [language]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMWReportLanguageTranslations] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWReportLanguageTranslations] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMWReportLanguageTranslations] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWReportLanguageTranslations] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWReportLanguageTranslations] TO [public]
GO
