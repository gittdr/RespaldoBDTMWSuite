CREATE TABLE [dbo].[RMXML_CarrierCoverage]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NOT NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[CoverageDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveDate] [datetime] NULL,
[ExpirationDate] [datetime] NULL,
[CancelDate] [datetime] NULL,
[PolicyNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Producer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProducerPhone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProducerFax] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProducerEmail] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Underwriter] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Confidence] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RMISCertID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RMISCovgID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastCertUpdate] [datetime] NULL,
[ConfidenceMsg] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RMISImageID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__RMXML_Car__lastu__1DED2FE6] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__RMXML_Car__lastu__1EE1541F] DEFAULT (suser_sname()),
[NAICCompanyNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AMBestCompanyNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProducerAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProducerCity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProducerState] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProducerZip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UnderwriterRating] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RMXML_CarrierCoverage] ADD CONSTRAINT [pk_rmxml_carriercoverage] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_CarrierCoverage_LastUpdateDate] ON [dbo].[RMXML_CarrierCoverage] ([lastupdatedate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_CarrierCoverage_PolicyNumber] ON [dbo].[RMXML_CarrierCoverage] ([PolicyNumber]) INCLUDE ([TmwXmlImportLog_id], [RootElementID], [CoverageDescription], [EffectiveDate], [ExpirationDate], [Producer], [ProducerPhone], [ProducerFax], [Underwriter]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_CarrierCoverage_TmwXmlImportLog_id] ON [dbo].[RMXML_CarrierCoverage] ([TmwXmlImportLog_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_CarrierCoverage] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_CarrierCoverage] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_CarrierCoverage] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_CarrierCoverage] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_CarrierCoverage] TO [public]
GO
