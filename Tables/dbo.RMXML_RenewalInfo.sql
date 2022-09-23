CREATE TABLE [dbo].[RMXML_RenewalInfo]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NOT NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[RenewalOnFile_CertID] [int] NULL,
[RenewalOnFile_EffectiveDate] [datetime] NULL,
[RenewalOnFile_ExpirationDate] [datetime] NULL,
[RenewalOnFile_ImageID] [int] NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__RMXML_Ren__lastu__3221D286] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__RMXML_Ren__lastu__3315F6BF] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RMXML_RenewalInfo] ADD CONSTRAINT [pk_rmxml_RenewalInfo] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_RenewalInfo_LastUpdateDate] ON [dbo].[RMXML_RenewalInfo] ([lastupdatedate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_RenewalInfo_TmwXmlImportLog_id] ON [dbo].[RMXML_RenewalInfo] ([TmwXmlImportLog_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_RenewalInfo] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_RenewalInfo] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_RenewalInfo] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_RenewalInfo] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_RenewalInfo] TO [public]
GO
