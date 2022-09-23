CREATE TABLE [dbo].[tblPropertyListEntries]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[PropSN] [int] NOT NULL,
[Value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultLength] [int] NULL,
[FldType] [int] NULL,
[EntryType] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblPropertyListEntries] ADD CONSTRAINT [PK_tblPropertyListEntries] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxPropSN] ON [dbo].[tblPropertyListEntries] ([PropSN], [Value]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblPropertyListEntries] TO [public]
GO
GRANT INSERT ON  [dbo].[tblPropertyListEntries] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblPropertyListEntries] TO [public]
GO
GRANT SELECT ON  [dbo].[tblPropertyListEntries] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblPropertyListEntries] TO [public]
GO
