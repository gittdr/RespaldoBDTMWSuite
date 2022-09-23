CREATE TABLE [dbo].[dx_SMTP]
(
[dx_ident] [bigint] NOT NULL IDENTITY(1, 1),
[dx_importid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_SMTPaddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_messagename] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_messagefrom] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_messageto] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_messagesubject] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_messageintro] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_messagebody] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_messagefooter] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_messagesignature] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_bodyformat] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_attachment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_SMTP] ADD CONSTRAINT [pk_dx_SMTP] PRIMARY KEY CLUSTERED ([dx_importid], [dx_messagename]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_SMTP] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_SMTP] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_SMTP] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_SMTP] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_SMTP] TO [public]
GO
