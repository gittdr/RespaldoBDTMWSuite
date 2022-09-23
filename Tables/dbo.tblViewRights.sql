CREATE TABLE [dbo].[tblViewRights]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[ViewCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispSysID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblViewRights] ADD CONSTRAINT [PK_tblViewRights] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblViewRights] TO [public]
GO
GRANT INSERT ON  [dbo].[tblViewRights] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblViewRights] TO [public]
GO
GRANT SELECT ON  [dbo].[tblViewRights] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblViewRights] TO [public]
GO
