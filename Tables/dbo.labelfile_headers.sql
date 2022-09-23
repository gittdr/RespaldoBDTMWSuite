CREATE TABLE [dbo].[labelfile_headers]
(
[CarType1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarType2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarType3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarType4] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DrvType1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DrvType2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DrvType3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DrvType4] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevType1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevType2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevType3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevType4] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrcType1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrcType2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrcType3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrcType4] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrlType1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrlType2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrlType3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrlType4] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LghType1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LghType2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LghPermitStatus] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BranchRoleUser1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BranchRoleUser2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BranchRoleUser3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BranchRoleUser4] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[labelfile_headers_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[labelfile_headers] ADD CONSTRAINT [prkey_labelfile_headers] PRIMARY KEY CLUSTERED ([labelfile_headers_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[labelfile_headers] TO [public]
GO
GRANT INSERT ON  [dbo].[labelfile_headers] TO [public]
GO
GRANT REFERENCES ON  [dbo].[labelfile_headers] TO [public]
GO
GRANT SELECT ON  [dbo].[labelfile_headers] TO [public]
GO
GRANT UPDATE ON  [dbo].[labelfile_headers] TO [public]
GO
