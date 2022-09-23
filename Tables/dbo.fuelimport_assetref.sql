CREATE TABLE [dbo].[fuelimport_assetref]
(
[far_id] [int] NOT NULL IDENTITY(1, 1),
[far_asgntype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[far_asgnid] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[far_cardvendor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[far_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[far_value] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NULL,
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fuelimport_assetref] ADD CONSTRAINT [PK_fuelimport_assetref] PRIMARY KEY CLUSTERED ([far_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_fuelimport_assetref_asgn] ON [dbo].[fuelimport_assetref] ([far_asgntype], [far_asgnid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_fuelimport_assetref_value] ON [dbo].[fuelimport_assetref] ([far_name], [far_value]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[fuelimport_assetref] TO [public]
GO
GRANT INSERT ON  [dbo].[fuelimport_assetref] TO [public]
GO
GRANT REFERENCES ON  [dbo].[fuelimport_assetref] TO [public]
GO
GRANT SELECT ON  [dbo].[fuelimport_assetref] TO [public]
GO
GRANT UPDATE ON  [dbo].[fuelimport_assetref] TO [public]
GO
