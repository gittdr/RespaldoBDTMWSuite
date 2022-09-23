CREATE TABLE [dbo].[tblMCProperties]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[PropMCSN] [int] NOT NULL,
[ResourceSN] [int] NOT NULL,
[ResourceType] [int] NOT NULL,
[Value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMCProperties] ADD CONSTRAINT [PK_tblMCProperties_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxfldSNPropSNMC] ON [dbo].[tblMCProperties] ([SN], [PropMCSN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblMCProperties] TO [public]
GO
GRANT INSERT ON  [dbo].[tblMCProperties] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblMCProperties] TO [public]
GO
GRANT SELECT ON  [dbo].[tblMCProperties] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblMCProperties] TO [public]
GO
