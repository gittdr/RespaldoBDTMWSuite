CREATE TABLE [dbo].[tblMembership]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Member] [int] NULL,
[GroupSN] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMembership] ADD CONSTRAINT [PK_tblMembership_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tblGroupstblMembership] ON [dbo].[tblMembership] ([GroupSN]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tblAddressestblMembership] ON [dbo].[tblMembership] ([Member]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMembership] ADD CONSTRAINT [FK__Temporary__Group__7FCB01AD] FOREIGN KEY ([GroupSN]) REFERENCES [dbo].[tblGroups] ([AddressSN])
GO
ALTER TABLE [dbo].[tblMembership] ADD CONSTRAINT [FK__Temporary__Membe__7ED6DD74] FOREIGN KEY ([Member]) REFERENCES [dbo].[tblAddressBook] ([SN])
GO
GRANT DELETE ON  [dbo].[tblMembership] TO [public]
GO
GRANT INSERT ON  [dbo].[tblMembership] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblMembership] TO [public]
GO
GRANT SELECT ON  [dbo].[tblMembership] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblMembership] TO [public]
GO
