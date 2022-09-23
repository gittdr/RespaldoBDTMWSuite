CREATE TABLE [dbo].[RMXML_PHMSA]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NOT NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[DotNumber] [int] NULL,
[MCNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mailing_Street] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mailing_City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mailing_State] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mailing_Zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mailing_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Physical_Street] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Physical_City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Physical_State] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Physical_Zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Physical_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HMCompanyID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RailroadCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegYearRaw] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegistrationExpiration] [datetime] NULL,
[RegistrationID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suspended] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsValid] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdated] [datetime] NULL,
[LastChecked] [datetime] NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__RMXML_PHM__lastu__26B01FDA] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__RMXML_PHM__lastu__27A44413] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RMXML_PHMSA] ADD CONSTRAINT [pk_rmxml_PHMSA] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_PHMSA_LastUpdateDate] ON [dbo].[RMXML_PHMSA] ([lastupdatedate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_PHMSA_TmwXmlImportLog_id] ON [dbo].[RMXML_PHMSA] ([TmwXmlImportLog_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_PHMSA] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_PHMSA] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_PHMSA] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_PHMSA] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_PHMSA] TO [public]
GO
