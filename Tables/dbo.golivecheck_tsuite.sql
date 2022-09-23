CREATE TABLE [dbo].[golivecheck_tsuite]
(
[glc_rundate] [datetime] NULL,
[glc_version] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[glc_trc_lic_count] [int] NULL,
[glc_remitto] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[golivecheck_tsuite] TO [public]
GO
GRANT INSERT ON  [dbo].[golivecheck_tsuite] TO [public]
GO
GRANT REFERENCES ON  [dbo].[golivecheck_tsuite] TO [public]
GO
GRANT SELECT ON  [dbo].[golivecheck_tsuite] TO [public]
GO
GRANT UPDATE ON  [dbo].[golivecheck_tsuite] TO [public]
GO
