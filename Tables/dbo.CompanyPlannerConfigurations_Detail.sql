CREATE TABLE [dbo].[CompanyPlannerConfigurations_Detail]
(
[cpd_Id] [int] NOT NULL IDENTITY(1, 1),
[cph_id] [int] NULL,
[pbc_id] [int] NULL,
[cpd_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_latcolumn] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_longcolumn] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_idcolumn] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_showMap] [bit] NULL,
[cpd_mapdetail] [int] NULL,
[cpd_labelcolumn] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_defaulticon] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_refreshtime] [int] NULL,
[cpd_zoomlevel] [int] NULL,
[cpd_initlat] [float] NULL,
[cpd_initlong] [float] NULL,
[cpd_initzoom] [int] NULL,
[cpd_iconcolumn] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_infocolumn] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_defaultmapview] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_xmlOptions] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_groupCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_CreatedOn] [datetime] NULL,
[cpd_LastUpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_LastUpdatedOn] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CompanyPlannerConfigurations_Detail] TO [public]
GO
GRANT INSERT ON  [dbo].[CompanyPlannerConfigurations_Detail] TO [public]
GO
GRANT SELECT ON  [dbo].[CompanyPlannerConfigurations_Detail] TO [public]
GO
GRANT UPDATE ON  [dbo].[CompanyPlannerConfigurations_Detail] TO [public]
GO
