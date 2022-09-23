CREATE TABLE [dbo].[RMXML_DOT]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NOT NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[dot_DocketNumber] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_USDOTNumber] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_CommonAuthority] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_ContractAuthority] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_BrokerAuthority] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_PendingCommonAuthority] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_PendingContractAuthority] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_PendingBrokerAuthority] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_CommonAuthRevocation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_ContractAuthRevocation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_BrokerAuthorityRevocation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_Freight] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_Passenger] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_HouseholdGoods] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_BIPDRequired] [money] NULL,
[dot_CargoRequired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_BondSuretyRequired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_BIPDOnFile] [money] NULL,
[dot_CargoOnFile] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_BondSuretyOnFile] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_AddressStatus] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_DBAName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_LegalName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_Business_Addr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_Business_City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_Business_St] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_Business_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_Business_Zip] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_Business_Phone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_Business_Fax] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_Mailing_Addr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_Mailing_City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_Mailing_St] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_Mailing_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_Mailing_Zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_Mailing_Phone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_Mailing_Fax] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dot_dateLastUpdated] [datetime] NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__RMXML_DOT__lastu__258E51AE] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__RMXML_DOT__lastu__268275E7] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RMXML_DOT] ADD CONSTRAINT [pk_rmxml_dot] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_DOT_LastUpdateDate] ON [dbo].[RMXML_DOT] ([lastupdatedate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_DOT_TmwXmlImportLog_id] ON [dbo].[RMXML_DOT] ([TmwXmlImportLog_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_DOT] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_DOT] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_DOT] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_DOT] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_DOT] TO [public]
GO
