CREATE TABLE [dbo].[EleosMsgTblHistory]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[handle] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[created_at] [datetime] NOT NULL CONSTRAINT [DF__EleosMsgT__creat__6C121218] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EleosMsgTblHistory] ADD CONSTRAINT [PK__EleosMsg__32151C6496BF6AA1] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
