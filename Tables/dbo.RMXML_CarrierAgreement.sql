CREATE TABLE [dbo].[RMXML_CarrierAgreement]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NOT NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[Date] [datetime] NULL,
[Contact] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Agree] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__RMXML_Car__lastu__0ADA5B72] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__RMXML_Car__lastu__0BCE7FAB] DEFAULT (suser_sname()),
[AgreementID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RMXML_CarrierAgreement] ADD CONSTRAINT [pk_rmxml_carrieragreement] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_CarrierAgreement_LastUpdateDate] ON [dbo].[RMXML_CarrierAgreement] ([lastupdatedate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_CarrierAgreement_TmwXmlImportLog_id] ON [dbo].[RMXML_CarrierAgreement] ([TmwXmlImportLog_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_CarrierAgreement] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_CarrierAgreement] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_CarrierAgreement] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_CarrierAgreement] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_CarrierAgreement] TO [public]
GO
