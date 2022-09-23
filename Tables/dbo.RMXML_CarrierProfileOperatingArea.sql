CREATE TABLE [dbo].[RMXML_CarrierProfileOperatingArea]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NOT NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[Area] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__RMXML_Car__lastu__127B7D3A] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__RMXML_Car__lastu__136FA173] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RMXML_CarrierProfileOperatingArea] ADD CONSTRAINT [pk_rmxml_carrierprofileoperatingarea] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_CarrierProfileOperatingArea_LastUpdateDate] ON [dbo].[RMXML_CarrierProfileOperatingArea] ([lastupdatedate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_CarrierProfileOperatingArea_TmwXmlImportLog_id] ON [dbo].[RMXML_CarrierProfileOperatingArea] ([TmwXmlImportLog_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_CarrierProfileOperatingArea] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_CarrierProfileOperatingArea] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_CarrierProfileOperatingArea] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_CarrierProfileOperatingArea] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_CarrierProfileOperatingArea] TO [public]
GO
