CREATE TABLE [dbo].[RMXML_CarrierProfileCommodities]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NOT NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[Commodity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__RMXML_Car__lastu__1A1C9F02] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__RMXML_Car__lastu__1B10C33B] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RMXML_CarrierProfileCommodities] ADD CONSTRAINT [pk_rmxml_carrierprofilecommodities] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_CarrierProfileCommodities_LastUpdateDate] ON [dbo].[RMXML_CarrierProfileCommodities] ([lastupdatedate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_CarrierProfileCommodities_TmwXmlImportLog_id] ON [dbo].[RMXML_CarrierProfileCommodities] ([TmwXmlImportLog_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_CarrierProfileCommodities] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_CarrierProfileCommodities] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_CarrierProfileCommodities] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_CarrierProfileCommodities] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_CarrierProfileCommodities] TO [public]
GO
