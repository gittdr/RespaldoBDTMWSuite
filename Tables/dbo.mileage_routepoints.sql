CREATE TABLE [dbo].[mileage_routepoints]
(
[mrp_origincity] [int] NOT NULL,
[mrp_destcity] [int] NOT NULL,
[mrp_sequence] [int] NOT NULL,
[mrp_mttype] [int] NOT NULL,
[mrp_latlong] [varchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mrp_origincmpid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mrp_destcmpid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mrp_identity] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[mileage_routepoints] ADD CONSTRAINT [pk_mileageroutepoints] PRIMARY KEY CLUSTERED ([mrp_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DIDX_mrp01] ON [dbo].[mileage_routepoints] ([mrp_origincity], [mrp_destcity], [mrp_mttype], [mrp_sequence]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DIDX_mrp03] ON [dbo].[mileage_routepoints] ([mrp_origincmpid], [mrp_destcmpid], [mrp_mttype], [mrp_sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[mileage_routepoints] TO [public]
GO
GRANT INSERT ON  [dbo].[mileage_routepoints] TO [public]
GO
GRANT SELECT ON  [dbo].[mileage_routepoints] TO [public]
GO
GRANT UPDATE ON  [dbo].[mileage_routepoints] TO [public]
GO
