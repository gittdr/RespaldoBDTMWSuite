CREATE TABLE [dbo].[CompanyContactLocation]
(
[ccl_id] [int] NOT NULL IDENTITY(1, 1),
[ce_id] [int] NOT NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ccl_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccl_createdate] [datetime] NULL,
[ccl_lastupdatedate] [datetime] NULL,
[ccl_createdby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccl_lastupdateby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyContactLocation] ADD CONSTRAINT [pk_CompanyContactLocation_id] PRIMARY KEY CLUSTERED ([ccl_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CompanyContactLocation] TO [public]
GO
GRANT INSERT ON  [dbo].[CompanyContactLocation] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CompanyContactLocation] TO [public]
GO
GRANT SELECT ON  [dbo].[CompanyContactLocation] TO [public]
GO
GRANT UPDATE ON  [dbo].[CompanyContactLocation] TO [public]
GO
