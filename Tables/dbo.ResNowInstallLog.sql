CREATE TABLE [dbo].[ResNowInstallLog]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[dt] [datetime] NULL CONSTRAINT [DF__ResNowInstal__dt__1F2FCD58] DEFAULT (getdate()),
[Note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ResNowInstallLog] ADD CONSTRAINT [AutoPK_ResNowInstallLog_SN] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
