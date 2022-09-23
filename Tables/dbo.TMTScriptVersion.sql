CREATE TABLE [dbo].[TMTScriptVersion]
(
[SCRIPTID] [int] NOT NULL IDENTITY(1, 1),
[SCRIPTKEY] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCRIPTNAME] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCRIPTDBVERSION] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCRIPTTIME] [datetime] NOT NULL CONSTRAINT [DF__TMTScript__SCRIPTTIME] DEFAULT (getdate()),
[MODIFIEDBY] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__TMTSCRIPTVERSION__MODIFIEDBY] DEFAULT (suser_sname()),
[MODIFIED] [smalldatetime] NULL CONSTRAINT [DF__TMTSCRIPTVERSION__MODIFIED] DEFAULT (CONVERT([smalldatetime],getdate()))
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMTScriptVersion] TO [public]
GO
GRANT INSERT ON  [dbo].[TMTScriptVersion] TO [public]
GO
GRANT SELECT ON  [dbo].[TMTScriptVersion] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMTScriptVersion] TO [public]
GO
