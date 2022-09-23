CREATE TABLE [dbo].[RMXML_CarrierContacts]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NOT NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[Type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompanyName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cell] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__RMXML_Car__lastu__0709CA8E] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__RMXML_Car__lastu__07FDEEC7] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RMXML_CarrierContacts] ADD CONSTRAINT [pk_rmxml_carriercontacts] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_CarrierContacts_LastUpdateDate] ON [dbo].[RMXML_CarrierContacts] ([lastupdatedate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_CarrierContacts_TmwXmlImportLog_id] ON [dbo].[RMXML_CarrierContacts] ([TmwXmlImportLog_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_CarrierContacts] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_CarrierContacts] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_CarrierContacts] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_CarrierContacts] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_CarrierContacts] TO [public]
GO
