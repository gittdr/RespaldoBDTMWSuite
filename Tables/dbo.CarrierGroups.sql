CREATE TABLE [dbo].[CarrierGroups]
(
[cgp_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cgp_carrier_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarrierGroups] ADD CONSTRAINT [PK_CarrierGroups] PRIMARY KEY CLUSTERED ([cgp_type], [cgp_carrier_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CarrierGroups] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierGroups] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CarrierGroups] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierGroups] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierGroups] TO [public]
GO
