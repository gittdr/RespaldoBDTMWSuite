CREATE TABLE [dbo].[tblDispatchLogins]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[LoginSN] [int] NULL,
[DispatchGroupSN] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblDispatchLogins] ADD CONSTRAINT [pk_tblDispatchLogins] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tblDispatcherstblDispatchLogin] ON [dbo].[tblDispatchLogins] ([DispatchGroupSN]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Login_DispatchGroup] ON [dbo].[tblDispatchLogins] ([LoginSN], [DispatchGroupSN]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblDispatchLogins] ADD CONSTRAINT [FK__Temporary__Dispa__7B064C90] FOREIGN KEY ([DispatchGroupSN]) REFERENCES [dbo].[tblDispatchGroup] ([SN])
GO
ALTER TABLE [dbo].[tblDispatchLogins] ADD CONSTRAINT [FK__Temporary__Login__7A122857] FOREIGN KEY ([LoginSN]) REFERENCES [dbo].[tblLogin] ([SN])
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblDispatchLogins].[LoginSN]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblDispatchLogins].[DispatchGroupSN]'
GO
GRANT DELETE ON  [dbo].[tblDispatchLogins] TO [public]
GO
GRANT INSERT ON  [dbo].[tblDispatchLogins] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblDispatchLogins] TO [public]
GO
GRANT SELECT ON  [dbo].[tblDispatchLogins] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblDispatchLogins] TO [public]
GO
