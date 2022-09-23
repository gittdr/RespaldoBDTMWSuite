CREATE TABLE [dbo].[tblMsgShareData]
(
[OrigMsgSN] [int] NOT NULL,
[MsgImage] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReadByName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReadByType] [int] NULL,
[DispSysKey1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispSysKey2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispSysKeyType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMsgShareData] ADD CONSTRAINT [aaaaatblMsgData_PK] PRIMARY KEY CLUSTERED ([OrigMsgSN]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblMsgShareData] TO [public]
GO
GRANT INSERT ON  [dbo].[tblMsgShareData] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblMsgShareData] TO [public]
GO
GRANT SELECT ON  [dbo].[tblMsgShareData] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblMsgShareData] TO [public]
GO
