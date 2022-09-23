CREATE TABLE [dbo].[TmwXmlImportLog]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[workflow_id] [int] NOT NULL,
[activity_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CarrierCSALogHdr_id] [int] NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__TmwXmlImp__lastu__77C786FE] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TmwXmlImp__lastu__78BBAB37] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TmwXmlImportLog] ADD CONSTRAINT [pk_TmwXmlImportLog] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TmwXmlImportLog_CarrierCSALogHdr_id] ON [dbo].[TmwXmlImportLog] ([CarrierCSALogHdr_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TmwXmlImportLog_workflow_id] ON [dbo].[TmwXmlImportLog] ([workflow_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TmwXmlImportLog] TO [public]
GO
GRANT INSERT ON  [dbo].[TmwXmlImportLog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TmwXmlImportLog] TO [public]
GO
GRANT SELECT ON  [dbo].[TmwXmlImportLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[TmwXmlImportLog] TO [public]
GO
