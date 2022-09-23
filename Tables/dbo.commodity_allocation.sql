CREATE TABLE [dbo].[commodity_allocation]
(
[ca_id] [int] NOT NULL IDENTITY(1, 1),
[ca_shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ca_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ca_month] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ca_year] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmd_class] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ca_allocation] [int] NULL,
[ca_lastupdatedby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ca_lastupdateddate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commodity_allocation] ADD CONSTRAINT [pk_commodity_allocation_cmpid_billto_date_cmdclass] PRIMARY KEY CLUSTERED ([ca_shipper], [ca_billto], [ca_month], [ca_year], [cmd_class]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_commodity_allocation_cmpid_date] ON [dbo].[commodity_allocation] ([ca_shipper], [ca_month], [ca_year]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[commodity_allocation] TO [public]
GO
GRANT INSERT ON  [dbo].[commodity_allocation] TO [public]
GO
GRANT REFERENCES ON  [dbo].[commodity_allocation] TO [public]
GO
GRANT SELECT ON  [dbo].[commodity_allocation] TO [public]
GO
GRANT UPDATE ON  [dbo].[commodity_allocation] TO [public]
GO
