CREATE TABLE [dbo].[RMXML_Errors]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NOT NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[Error] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__RMXML_Err__lastu__7F68A8C6] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__RMXML_Err__lastu__005CCCFF] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RMXML_Errors] ADD CONSTRAINT [pk_rmxml_error] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_Errors_LastUpdateDate] ON [dbo].[RMXML_Errors] ([lastupdatedate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_Errors_TmwXmlImportLog_id] ON [dbo].[RMXML_Errors] ([TmwXmlImportLog_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_Errors] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_Errors] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_Errors] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_Errors] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_Errors] TO [public]
GO
