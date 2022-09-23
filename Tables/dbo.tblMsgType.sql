CREATE TABLE [dbo].[tblMsgType]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Code] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CodeDisplay] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMsgType] ADD CONSTRAINT [PK_tblMsgType_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Code] ON [dbo].[tblMsgType] ([Code]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[tblMsgType_Code_D]', N'[dbo].[tblMsgType].[Code]'
GO
EXEC sp_bindefault N'[dbo].[tblMsgType_Description_D]', N'[dbo].[tblMsgType].[Description]'
GO
GRANT DELETE ON  [dbo].[tblMsgType] TO [public]
GO
GRANT INSERT ON  [dbo].[tblMsgType] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblMsgType] TO [public]
GO
GRANT SELECT ON  [dbo].[tblMsgType] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblMsgType] TO [public]
GO
