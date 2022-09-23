CREATE TABLE [dbo].[tblTMApplicationLog]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[MCSN] [int] NULL,
[MCInstance] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PollerInstance] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MessageDate] [datetime] NULL,
[AssemblyName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ModuleName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MethodName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StepDescription] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Message] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SessionID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblTMApplicationLog] ADD CONSTRAINT [pk_tblTMApplicationLog] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tblTMApplicationLog_MsgDate_SN] ON [dbo].[tblTMApplicationLog] ([MessageDate], [SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblTMApplicationLog] TO [public]
GO
GRANT INSERT ON  [dbo].[tblTMApplicationLog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblTMApplicationLog] TO [public]
GO
GRANT SELECT ON  [dbo].[tblTMApplicationLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblTMApplicationLog] TO [public]
GO
