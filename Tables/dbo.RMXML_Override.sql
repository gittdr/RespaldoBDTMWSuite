CREATE TABLE [dbo].[RMXML_Override]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[OverrideType] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OverrideCreateDate] [datetime] NULL,
[OverrideExpirationDate] [datetime] NULL,
[OverrideAuthorizedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OverrideCreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NULL CONSTRAINT [DF__RMXML_Ove__lastu__42583A4F] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__RMXML_Ove__lastu__434C5E88] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_Override] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_Override] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_Override] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_Override] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_Override] TO [public]
GO
