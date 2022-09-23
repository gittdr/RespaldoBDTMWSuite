CREATE TABLE [dbo].[RMXML_ClientCarrierAgreementRuleOverrides]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NOT NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[ClientAgreementID] [int] NULL,
[AgreementTitle] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExpirationDate] [datetime] NULL,
[Note] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OverrideDate] [datetime] NULL,
[OverrideEditBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__RMXML_Cli__lastu__2E5141A2] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__RMXML_Cli__lastu__2F4565DB] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RMXML_ClientCarrierAgreementRuleOverrides] ADD CONSTRAINT [pk_rmxml_ClientCarrierAgreementRuleOverrides] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_ClientCarrierAgreementRuleOverrides_LastUpdateDate] ON [dbo].[RMXML_ClientCarrierAgreementRuleOverrides] ([lastupdatedate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_ClientCarrierAgreementRuleOverrides_TmwXmlImportLog_id] ON [dbo].[RMXML_ClientCarrierAgreementRuleOverrides] ([TmwXmlImportLog_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_ClientCarrierAgreementRuleOverrides] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_ClientCarrierAgreementRuleOverrides] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_ClientCarrierAgreementRuleOverrides] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_ClientCarrierAgreementRuleOverrides] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_ClientCarrierAgreementRuleOverrides] TO [public]
GO
