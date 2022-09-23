CREATE TABLE [dbo].[ResNowVersionLog]
(
[Version] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrentDBVersion] [bit] NULL CONSTRAINT [DF__ResNowVer__Curre__06641F8E] DEFAULT ((0)),
[DtApplied] [datetime] NULL,
[Comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResNowVersionLog_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ResNowVersionLog] ADD CONSTRAINT [prkey_ResNowVersionLog] PRIMARY KEY CLUSTERED ([ResNowVersionLog_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ResNowVersionLog] TO [public]
GO
GRANT SELECT ON  [dbo].[ResNowVersionLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[ResNowVersionLog] TO [public]
GO
