CREATE TABLE [dbo].[RMXML_W9]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NOT NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[W9ID] [int] NULL,
[TaxID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BusinessName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompanyType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsLimitedLiabCo] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LimitedLiabTaxClass] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsExemptPayee] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ST] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TINIsValid] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TINValidationReason] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TINCheckedDate] [datetime] NULL,
[TINCheckedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaxIDEIN] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaxIDSSN] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__RMXML_W9__lastup__39C2F44E] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__RMXML_W9__lastup__3AB71887] DEFAULT (suser_sname()),
[ExemptPayeeCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExemptFATCAcode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RMXML_W9] ADD CONSTRAINT [pk_RMXML_W9] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_W9_LastUpdateDate] ON [dbo].[RMXML_W9] ([lastupdatedate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_W9_TmwXmlImportLog_id] ON [dbo].[RMXML_W9] ([TmwXmlImportLog_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_W9] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_W9] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_W9] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_W9] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_W9] TO [public]
GO
