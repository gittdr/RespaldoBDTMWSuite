CREATE TABLE [dbo].[tblMCTypeProperties_defunct]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[MCSN] [int] NULL,
[PropSN] [int] NOT NULL,
[Value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InstanceID] [int] NULL,
[SeqNo] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxfldSNPropSN] ON [dbo].[tblMCTypeProperties_defunct] ([SN], [PropSN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblMCTypeProperties_defunct] TO [public]
GO
GRANT INSERT ON  [dbo].[tblMCTypeProperties_defunct] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblMCTypeProperties_defunct] TO [public]
GO
GRANT SELECT ON  [dbo].[tblMCTypeProperties_defunct] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblMCTypeProperties_defunct] TO [public]
GO
