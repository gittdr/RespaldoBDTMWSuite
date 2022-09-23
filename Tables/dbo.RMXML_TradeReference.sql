CREATE TABLE [dbo].[RMXML_TradeReference]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[TradeReferenceCompanyName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TradeReferenceContactName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TradeReferencePhone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TradeReferenceEmail] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TradeReferenceDateStamp] [datetime] NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NULL CONSTRAINT [DF__RMXML_Tra__lastu__3F7BCDA4] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__RMXML_Tra__lastu__406FF1DD] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_TradeReference] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_TradeReference] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_TradeReference] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_TradeReference] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_TradeReference] TO [public]
GO
