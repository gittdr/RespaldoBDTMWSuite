CREATE TABLE [dbo].[tblDispatchGroup]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InBox] [int] NULL,
[DispSysDispatcherID] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Retired] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblDispatchGroup] ADD CONSTRAINT [pk_tblDispatchGroup] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DispSysDispatcherID] ON [dbo].[tblDispatchGroup] ([DispSysDispatcherID]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [InBox] ON [dbo].[tblDispatchGroup] ([InBox]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Name] ON [dbo].[tblDispatchGroup] ([Name]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblDispatchGroup].[InBox]'
GO
GRANT DELETE ON  [dbo].[tblDispatchGroup] TO [public]
GO
GRANT INSERT ON  [dbo].[tblDispatchGroup] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblDispatchGroup] TO [public]
GO
GRANT SELECT ON  [dbo].[tblDispatchGroup] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblDispatchGroup] TO [public]
GO
