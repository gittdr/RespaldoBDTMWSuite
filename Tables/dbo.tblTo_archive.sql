CREATE TABLE [dbo].[tblTo_archive]
(
[SN] [int] NOT NULL,
[Message] [int] NULL,
[ToName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToType] [int] NULL,
[DTTransferred] [datetime] NULL,
[IsCC] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblTo_archive] ADD CONSTRAINT [PK_tblTo_archive] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_tblTo_Archive_SN] ON [dbo].[tblTo_archive] ([SN]) ON [PRIMARY]
GO
