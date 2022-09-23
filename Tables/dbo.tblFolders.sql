CREATE TABLE [dbo].[tblFolders]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Parent] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Owner] [int] NULL,
[IsPublic] [bit] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[tmail_no_empty_foldernames] ON [dbo].[tblFolders] FOR UPDATE, INSERT
AS
IF EXISTS (SELECT * FROM inserted WHERE ISNULL(name, '') = '' OR ISNULL(name, '') = 'MC Unit: ''s Private Folders')
  BEGIN
	ROLLBACK
	RAISERROR ('Attempt to create a folder with no name. Please contact TMW support immediately.', 16, 1)
  END
GO
ALTER TABLE [dbo].[tblFolders] ADD CONSTRAINT [PK_tblFolders_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tblFoldersParent] ON [dbo].[tblFolders] ([Parent], [SN]) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[tblFolders_Parent_D]', N'[dbo].[tblFolders].[Parent]'
GO
EXEC sp_bindefault N'[dbo].[tblFolders_Name_D]', N'[dbo].[tblFolders].[Name]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblFolders].[Owner]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblFolders].[IsPublic]'
GO
GRANT DELETE ON  [dbo].[tblFolders] TO [public]
GO
GRANT INSERT ON  [dbo].[tblFolders] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblFolders] TO [public]
GO
GRANT SELECT ON  [dbo].[tblFolders] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblFolders] TO [public]
GO
