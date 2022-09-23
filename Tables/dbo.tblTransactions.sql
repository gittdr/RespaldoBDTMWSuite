CREATE TABLE [dbo].[tblTransactions]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[FormIn] [int] NULL,
[FormOut] [int] NULL,
[Description] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InCopyToDispatcher] [bit] NOT NULL,
[OutCopyToDispatcher] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblTransactions] ADD CONSTRAINT [PK_tblTransactions_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[tblTransactions_Description_]', N'[dbo].[tblTransactions].[Description]'
GO
EXEC sp_bindefault N'[dbo].[tblTransactions_InCopyToDisp]', N'[dbo].[tblTransactions].[InCopyToDispatcher]'
GO
EXEC sp_bindefault N'[dbo].[tblTransactions_OutCopyToDis]', N'[dbo].[tblTransactions].[OutCopyToDispatcher]'
GO
GRANT DELETE ON  [dbo].[tblTransactions] TO [public]
GO
GRANT INSERT ON  [dbo].[tblTransactions] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblTransactions] TO [public]
GO
GRANT SELECT ON  [dbo].[tblTransactions] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblTransactions] TO [public]
GO
