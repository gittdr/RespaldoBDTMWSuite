CREATE TABLE [dbo].[ResNowZip3Translation]
(
[PID] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LowZip] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HighZip] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResNowZip3Translation_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ResNowZip3Translation] ADD CONSTRAINT [prkey_ResNowZip3Translation] PRIMARY KEY CLUSTERED ([ResNowZip3Translation_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ResNowZip3Translation] TO [public]
GO
GRANT INSERT ON  [dbo].[ResNowZip3Translation] TO [public]
GO
GRANT SELECT ON  [dbo].[ResNowZip3Translation] TO [public]
GO
GRANT UPDATE ON  [dbo].[ResNowZip3Translation] TO [public]
GO
