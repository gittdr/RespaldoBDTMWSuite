CREATE TABLE [dbo].[tblErrMsgText]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[RawText] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ErrText] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[insertdate] [datetime] NULL CONSTRAINT [DF__tblErrMsg__inser__484096CC] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblErrMsgText] ADD CONSTRAINT [PK_tblErrMsgText] PRIMARY KEY CLUSTERED ([SN], [RawText]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblErrMsgText] TO [public]
GO
GRANT INSERT ON  [dbo].[tblErrMsgText] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblErrMsgText] TO [public]
GO
GRANT SELECT ON  [dbo].[tblErrMsgText] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblErrMsgText] TO [public]
GO
