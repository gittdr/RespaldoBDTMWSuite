CREATE TABLE [dbo].[tblMsgProperties_Archive]
(
[MsgSN] [int] NOT NULL,
[PropSN] [int] NOT NULL,
[Value] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMsgProperties_Archive] ADD CONSTRAINT [PK_tblMsgProperties_Archive] PRIMARY KEY CLUSTERED ([MsgSN], [PropSN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_tblMsgProperties_Archive_MsgSN] ON [dbo].[tblMsgProperties_Archive] ([MsgSN]) ON [PRIMARY]
GO
