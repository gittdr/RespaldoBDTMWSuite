CREATE TABLE [dbo].[RMXML_CarrierCoverageLimit]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NOT NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[LimitDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LimitAmount] [money] NULL,
[RMISLimitID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__RMXML_Car__lastu__21BDC0CA] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__RMXML_Car__lastu__22B1E503] DEFAULT (suser_sname()),
[LimitCurrency] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RMXML_CarrierCoverageLimit] ADD CONSTRAINT [pk_rmxml_carriercoveragelimit] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_CarrierCoverageLimit_LastUpdateDate] ON [dbo].[RMXML_CarrierCoverageLimit] ([lastupdatedate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_CarrierCoverageLimit_TmwXmlImportLog_id] ON [dbo].[RMXML_CarrierCoverageLimit] ([TmwXmlImportLog_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_CarrierCoverageLimit] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_CarrierCoverageLimit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_CarrierCoverageLimit] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_CarrierCoverageLimit] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_CarrierCoverageLimit] TO [public]
GO
