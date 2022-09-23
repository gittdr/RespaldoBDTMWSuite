CREATE TABLE [dbo].[RMXML_CarrierProfileModes]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NOT NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[Mode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__RMXML_Car__lastu__164C0E1E] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__RMXML_Car__lastu__17403257] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RMXML_CarrierProfileModes] ADD CONSTRAINT [pk_rmxml_carrierprofilemodes] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_CarrierProfileModes_LastUpdateDate] ON [dbo].[RMXML_CarrierProfileModes] ([lastupdatedate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_CarrierProfileModes_TmwXmlImportLog_id] ON [dbo].[RMXML_CarrierProfileModes] ([TmwXmlImportLog_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_CarrierProfileModes] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_CarrierProfileModes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_CarrierProfileModes] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_CarrierProfileModes] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_CarrierProfileModes] TO [public]
GO
