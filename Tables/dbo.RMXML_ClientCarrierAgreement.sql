CREATE TABLE [dbo].[RMXML_ClientCarrierAgreement]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NOT NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[AgreementTitle] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Date] [datetime] NULL,
[Contact] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Agree] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AgreementID] [int] NULL,
[OverrideDate] [datetime] NULL,
[OverrideEditBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__RMXML_Cli__lastu__2A80B0BE] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__RMXML_Cli__lastu__2B74D4F7] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RMXML_ClientCarrierAgreement] ADD CONSTRAINT [pk_rmxml_ClientCarrierAgreement] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_ClientCarrierAgreement_LastUpdateDate] ON [dbo].[RMXML_ClientCarrierAgreement] ([lastupdatedate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_ClientCarrierAgreement_TmwXmlImportLog_id] ON [dbo].[RMXML_ClientCarrierAgreement] ([TmwXmlImportLog_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_ClientCarrierAgreement] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_ClientCarrierAgreement] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_ClientCarrierAgreement] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_ClientCarrierAgreement] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_ClientCarrierAgreement] TO [public]
GO
