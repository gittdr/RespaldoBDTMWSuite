CREATE TABLE [dbo].[tblGroups]
(
[AddressSN] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblGroups] ADD CONSTRAINT [PK_tblGroups_AddressSN] PRIMARY KEY CLUSTERED ([AddressSN]) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[tblGroups_Name_D]', N'[dbo].[tblGroups].[Name]'
GO
GRANT DELETE ON  [dbo].[tblGroups] TO [public]
GO
GRANT INSERT ON  [dbo].[tblGroups] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblGroups] TO [public]
GO
GRANT SELECT ON  [dbo].[tblGroups] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblGroups] TO [public]
GO
