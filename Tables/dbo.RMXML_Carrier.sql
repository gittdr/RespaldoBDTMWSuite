CREATE TABLE [dbo].[RMXML_Carrier]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NOT NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[CompanyName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RMISCarrierID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaxID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCNumber] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOTNumber] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[St] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Payto] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaytoAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaytoAddress2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaytoCity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaytoSt] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaytoZip] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaytoCountry] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientsCarrierID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[insdIntraStateNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[insdIntraStateState] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DUNs] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__RMXML_Car__lastu__033939AA] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__RMXML_Car__lastu__042D5DE3] DEFAULT (suser_sname()),
[PayToEmail] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsFactoring] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RMXML_Carrier] ADD CONSTRAINT [pk_rmxml_carrier] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_Carrier_DOTNumber] ON [dbo].[RMXML_Carrier] ([DOTNumber]) INCLUDE ([TmwXmlImportLog_id], [RootElementID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_Carrier_LastUpdateDate] ON [dbo].[RMXML_Carrier] ([lastupdatedate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_Carrier_MCNumber] ON [dbo].[RMXML_Carrier] ([MCNumber]) INCLUDE ([TmwXmlImportLog_id], [RootElementID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_Carrier_TmwXmlImportLog_id] ON [dbo].[RMXML_Carrier] ([TmwXmlImportLog_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_Carrier_TmwXmlImportLog_id_ParentLevel_Dot] ON [dbo].[RMXML_Carrier] ([TmwXmlImportLog_id], [ParentLevel]) INCLUDE ([DOTNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_Carrier_TmwXmlImportLog_id_ParentLevel] ON [dbo].[RMXML_Carrier] ([TmwXmlImportLog_id], [ParentLevel]) INCLUDE ([MCNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_Carrier_TmwXmlImportLog_id_RootElementID_Dot] ON [dbo].[RMXML_Carrier] ([TmwXmlImportLog_id], [RootElementID]) INCLUDE ([DOTNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_Carrier_TmwXmlImportLog_id_RootElementID] ON [dbo].[RMXML_Carrier] ([TmwXmlImportLog_id], [RootElementID]) INCLUDE ([MCNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_Carrier] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_Carrier] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_Carrier] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_Carrier] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_Carrier] TO [public]
GO
