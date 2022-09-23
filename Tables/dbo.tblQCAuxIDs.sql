CREATE TABLE [dbo].[tblQCAuxIDs]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AuxiliaryID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblQCAuxIDs] ADD CONSTRAINT [PK_tblQCAuxIDs] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblQCAuxIDs] TO [public]
GO
GRANT INSERT ON  [dbo].[tblQCAuxIDs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblQCAuxIDs] TO [public]
GO
GRANT SELECT ON  [dbo].[tblQCAuxIDs] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblQCAuxIDs] TO [public]
GO
