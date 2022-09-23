CREATE TABLE [dbo].[RMXML_CertificationStatus]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[StatusDate] [datetime] NULL,
[IsCertified] [bit] NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NULL CONSTRAINT [DF__RMXML_Cer__lastu__481113A5] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__RMXML_Cer__lastu__490537DE] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_CertificationStatus] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_CertificationStatus] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_CertificationStatus] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_CertificationStatus] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_CertificationStatus] TO [public]
GO
