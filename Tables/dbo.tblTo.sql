CREATE TABLE [dbo].[tblTo]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Message] [int] NULL,
[ToName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToType] [int] NULL,
[DTTransferred] [datetime] NULL,
[IsCC] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblTo] ADD CONSTRAINT [PK_tblTo_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
