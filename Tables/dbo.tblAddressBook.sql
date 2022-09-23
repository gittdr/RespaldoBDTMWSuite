CREATE TABLE [dbo].[tblAddressBook]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[DefaultAddress] [int] NULL,
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UseInResolve] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblAddressBook] ADD CONSTRAINT [PK_tblAddressBook_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxDefaultAddress] ON [dbo].[tblAddressBook] ([DefaultAddress]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [Name] ON [dbo].[tblAddressBook] ([Name]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblAddressBook].[DefaultAddress]'
GO
EXEC sp_bindefault N'[dbo].[tblAddressBook_Name_D]', N'[dbo].[tblAddressBook].[Name]'
GO
EXEC sp_bindefault N'[dbo].[tblAddressBook_UseInResolve_]', N'[dbo].[tblAddressBook].[UseInResolve]'
GO
GRANT DELETE ON  [dbo].[tblAddressBook] TO [public]
GO
GRANT INSERT ON  [dbo].[tblAddressBook] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblAddressBook] TO [public]
GO
GRANT SELECT ON  [dbo].[tblAddressBook] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblAddressBook] TO [public]
GO
