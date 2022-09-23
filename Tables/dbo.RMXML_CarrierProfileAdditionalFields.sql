CREATE TABLE [dbo].[RMXML_CarrierProfileAdditionalFields]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NOT NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[value] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__RMXML_Car__lastu__35F2636A] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__RMXML_Car__lastu__36E687A3] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RMXML_CarrierProfileAdditionalFields] ADD CONSTRAINT [pk_rmxml_CarrierProfileAdditionalFields] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_CarrierProfileAdditionalFields_LastUpdateDate] ON [dbo].[RMXML_CarrierProfileAdditionalFields] ([lastupdatedate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_CarrierProfileAdditionalFields_TmwXmlImportLog_id] ON [dbo].[RMXML_CarrierProfileAdditionalFields] ([TmwXmlImportLog_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_CarrierProfileAdditionalFields] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_CarrierProfileAdditionalFields] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_CarrierProfileAdditionalFields] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_CarrierProfileAdditionalFields] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_CarrierProfileAdditionalFields] TO [public]
GO
