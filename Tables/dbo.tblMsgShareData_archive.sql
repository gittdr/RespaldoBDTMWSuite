CREATE TABLE [dbo].[tblMsgShareData_archive]
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
ALTER TABLE [dbo].[tblMsgShareData_archive] ADD CONSTRAINT [PK_tblMsgShareData_archive] PRIMARY KEY CLUSTERED ([OrigMsgSN]) ON [PRIMARY]
GO
