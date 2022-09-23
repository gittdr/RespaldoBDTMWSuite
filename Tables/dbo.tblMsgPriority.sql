CREATE TABLE [dbo].[tblMsgPriority]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Code] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Value] [int] NULL,
[Description] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMsgPriority] ADD CONSTRAINT [PK_tblMsgPriority_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Code] ON [dbo].[tblMsgPriority] ([Code]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[tblMsgPriority_Code_D]', N'[dbo].[tblMsgPriority].[Code]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblMsgPriority].[Value]'
GO
GRANT DELETE ON  [dbo].[tblMsgPriority] TO [public]
GO
GRANT INSERT ON  [dbo].[tblMsgPriority] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblMsgPriority] TO [public]
GO
GRANT SELECT ON  [dbo].[tblMsgPriority] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblMsgPriority] TO [public]
GO
