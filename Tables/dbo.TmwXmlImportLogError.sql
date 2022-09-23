CREATE TABLE [dbo].[TmwXmlImportLogError]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NOT NULL,
[ErrorInfo] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__TmwXmlImp__lastu__7B9817E2] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TmwXmlImp__lastu__7C8C3C1B] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TmwXmlImportLogError] ADD CONSTRAINT [pk_TmwXmlImportLogError] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TmwXmlImportLogError_LastUpdateDate] ON [dbo].[TmwXmlImportLogError] ([lastupdatedate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TmwXmlImportLogError_TmwXmlImportLog_id] ON [dbo].[TmwXmlImportLogError] ([TmwXmlImportLog_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TmwXmlImportLogError] TO [public]
GO
GRANT INSERT ON  [dbo].[TmwXmlImportLogError] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TmwXmlImportLogError] TO [public]
GO
GRANT SELECT ON  [dbo].[TmwXmlImportLogError] TO [public]
GO
GRANT UPDATE ON  [dbo].[TmwXmlImportLogError] TO [public]
GO
