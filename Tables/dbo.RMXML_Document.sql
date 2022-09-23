CREATE TABLE [dbo].[RMXML_Document]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[DocumentID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDatePST] [datetime] NULL,
[FileType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileSize] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UploadBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UploadMode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NULL CONSTRAINT [DF__RMXML_Doc__lastu__4534A6FA] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__RMXML_Doc__lastu__4628CB33] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_Document] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_Document] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_Document] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_Document] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_Document] TO [public]
GO
