CREATE TABLE [dbo].[OrderImportDedicated_audit]
(
[LoadID] [int] NULL,
[Departuredate] [datetime] NULL,
[Message] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [int] NULL,
[Sequence] [int] NULL,
[sFilename] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OrderImportDedicated_audit] TO [public]
GO
GRANT INSERT ON  [dbo].[OrderImportDedicated_audit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[OrderImportDedicated_audit] TO [public]
GO
GRANT SELECT ON  [dbo].[OrderImportDedicated_audit] TO [public]
GO
GRANT UPDATE ON  [dbo].[OrderImportDedicated_audit] TO [public]
GO
