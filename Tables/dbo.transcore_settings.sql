CREATE TABLE [dbo].[transcore_settings]
(
[tss_identity] [int] NOT NULL IDENTITY(1, 1),
[tss_account] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tss_subaccount] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tss_ftpaddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tss_ftplogin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tss_ftppassword] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tss_callbacknumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tss_dispatcherid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tss_tcpport] [int] NULL,
[tss_default_backhaul] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tss_default_comment1] [varchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tss_default_comment2] [varchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[transcore_settings] ADD CONSTRAINT [PK_transcore_settings] PRIMARY KEY CLUSTERED ([tss_identity]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[transcore_settings] TO [public]
GO
GRANT INSERT ON  [dbo].[transcore_settings] TO [public]
GO
GRANT REFERENCES ON  [dbo].[transcore_settings] TO [public]
GO
GRANT SELECT ON  [dbo].[transcore_settings] TO [public]
GO
GRANT UPDATE ON  [dbo].[transcore_settings] TO [public]
GO
