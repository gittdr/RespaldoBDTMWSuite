CREATE TABLE [dbo].[FTPReadingImportSettings]
(
[Sequence] [int] NOT NULL,
[FTPSite] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileMask] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_FTPReadingImportSettings_FileMask] DEFAULT ('*.txt'),
[Directory] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Username] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Password] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NumberOfFilesToArchive] [int] NOT NULL CONSTRAINT [DF_FTPReadingImportSettings_NumberOfFilesToArchive] DEFAULT ((0)),
[AlwaysUseSQLForCompanyLookupImport] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_FTPReadingImportSettings_AlwaysUseSQLForCompanyLookupImport] DEFAULT ('N'),
[CompanyLookupImportSQL] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_FTPReadingImportSettings_CreatedDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_FTPReadingImportSettings_ModifiedDate] DEFAULT (getdate()),
[FTPType] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_FTPReadingImportSettings_FTPType] DEFAULT ('READING')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FTPReadingImportSettings] ADD CONSTRAINT [PK_FTPReadingImportSettings] PRIMARY KEY CLUSTERED ([Sequence], [FTPType]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FTPReadingImportSettings] TO [public]
GO
GRANT INSERT ON  [dbo].[FTPReadingImportSettings] TO [public]
GO
GRANT SELECT ON  [dbo].[FTPReadingImportSettings] TO [public]
GO
GRANT UPDATE ON  [dbo].[FTPReadingImportSettings] TO [public]
GO
