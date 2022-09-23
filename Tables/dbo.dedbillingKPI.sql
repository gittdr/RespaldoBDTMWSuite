CREATE TABLE [dbo].[dedbillingKPI]
(
[dbkpi_id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dbsd_id] [int] NULL,
[dbkpi_days] [int] NULL,
[dbkpi_charge] [money] NULL,
[dbkpi_enddate] [datetime] NULL,
[dbkpi_createdate] [datetime] NULL,
[dbkpi_upddateddate] [datetime] NULL,
[dbkpi_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dedbillingKPI] ADD CONSTRAINT [pk_dbkpi_id] PRIMARY KEY CLUSTERED ([dbkpi_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_cmp_id] ON [dbo].[dedbillingKPI] ([cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dedbillingKPI] TO [public]
GO
GRANT INSERT ON  [dbo].[dedbillingKPI] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dedbillingKPI] TO [public]
GO
GRANT SELECT ON  [dbo].[dedbillingKPI] TO [public]
GO
GRANT UPDATE ON  [dbo].[dedbillingKPI] TO [public]
GO
