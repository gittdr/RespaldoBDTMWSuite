CREATE TABLE [dbo].[golivecheck_version]
(
[glc_versdate] [datetime] NULL,
[glc_sp_version] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[golivecheck_version] TO [public]
GO
GRANT INSERT ON  [dbo].[golivecheck_version] TO [public]
GO
GRANT REFERENCES ON  [dbo].[golivecheck_version] TO [public]
GO
GRANT SELECT ON  [dbo].[golivecheck_version] TO [public]
GO
GRANT UPDATE ON  [dbo].[golivecheck_version] TO [public]
GO
