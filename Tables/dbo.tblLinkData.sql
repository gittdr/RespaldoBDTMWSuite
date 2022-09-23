CREATE TABLE [dbo].[tblLinkData]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[LinkSN] [int] NULL,
[Type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Field1SN] [int] NULL,
[Field2SN] [int] NULL,
[Repetitions] [int] NULL,
[AllowEdit] [int] NULL,
[Seq] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblLinkData] ADD CONSTRAINT [LinkData_Primary_Key_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblLinkData] TO [public]
GO
GRANT INSERT ON  [dbo].[tblLinkData] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblLinkData] TO [public]
GO
GRANT SELECT ON  [dbo].[tblLinkData] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblLinkData] TO [public]
GO
