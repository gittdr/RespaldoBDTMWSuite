CREATE TABLE [dbo].[branch_drivertype1]
(
[brn_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mpp_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bdt_comparisonflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bdt_genericflag1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bdt_genericflag2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bdt_genericflag3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bdt_genericflag4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bdt_createdby] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bdt_createddate] [datetime] NULL,
[bdt_updatedby] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bdt_updateddate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[branch_drivertype1] ADD CONSTRAINT [pk_branch_drivertype] PRIMARY KEY CLUSTERED ([brn_id], [mpp_type1], [bdt_comparisonflag]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[branch_drivertype1] TO [public]
GO
GRANT INSERT ON  [dbo].[branch_drivertype1] TO [public]
GO
GRANT REFERENCES ON  [dbo].[branch_drivertype1] TO [public]
GO
GRANT SELECT ON  [dbo].[branch_drivertype1] TO [public]
GO
GRANT UPDATE ON  [dbo].[branch_drivertype1] TO [public]
GO
