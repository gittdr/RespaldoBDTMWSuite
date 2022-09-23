CREATE TABLE [dbo].[tblLogin]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[LoginName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TMPassword] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAPIProfile] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Password] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InBox] [int] NULL,
[OutBox] [int] NULL,
[Sent] [int] NULL,
[Deleted] [int] NULL,
[LastTMDlvry] [datetime] NULL,
[DefaultFilterSN] [int] NULL CONSTRAINT [DF__tbllogin__Defaul__10E07F16] DEFAULT (0),
[UseAdminMailBox] [int] NOT NULL CONSTRAINT [DF__tblLogin__UseAdm__085B1BE1] DEFAULT (0),
[SMTPReplyAddress] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tblLogin__SMTPRe__0B37888C] DEFAULT (''),
[EmailFolderID] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__tblLogin__EmailF__0E13F537] DEFAULT (''),
[AfterEmailSend] [int] NOT NULL CONSTRAINT [DF__tblLogin__AfterE__10F061E2] DEFAULT (0),
[SMTPLogin] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tblLogin__SMTPLo__13CCCE8D] DEFAULT (''),
[SMTPPassword] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__tblLogin__SMTPPa__16A93B38] DEFAULT (''),
[EMailFolderName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__tblLogin__EMailF__1985A7E3] DEFAULT (''),
[AlternateID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__tblLogin__Altern__1C62148E] DEFAULT (''),
[TimeZone] [int] NULL,
[DSTCode] [int] NULL,
[TZMinutes] [int] NULL,
[NTLoginName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Retired] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblLogin] ADD CONSTRAINT [PK_tblLogin_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [LoginName] ON [dbo].[tblLogin] ([LoginName]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblLogin] TO [public]
GO
GRANT INSERT ON  [dbo].[tblLogin] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblLogin] TO [public]
GO
GRANT SELECT ON  [dbo].[tblLogin] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblLogin] TO [public]
GO
