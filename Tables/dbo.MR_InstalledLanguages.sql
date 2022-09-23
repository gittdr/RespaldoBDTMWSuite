CREATE TABLE [dbo].[MR_InstalledLanguages]
(
[ir_language] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MR_InstalledLanguages] ADD CONSTRAINT [PK_MR_InstalledTranslations] PRIMARY KEY CLUSTERED ([ir_language]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MR_InstalledLanguages] TO [public]
GO
GRANT INSERT ON  [dbo].[MR_InstalledLanguages] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MR_InstalledLanguages] TO [public]
GO
GRANT SELECT ON  [dbo].[MR_InstalledLanguages] TO [public]
GO
GRANT UPDATE ON  [dbo].[MR_InstalledLanguages] TO [public]
GO
