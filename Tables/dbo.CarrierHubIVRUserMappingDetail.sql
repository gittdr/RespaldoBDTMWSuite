CREATE TABLE [dbo].[CarrierHubIVRUserMappingDetail]
(
[CarrierHubUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsBillTo] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarrierHubIVRUserMappingDetail] ADD CONSTRAINT [PK_CarrierHubIVRUserMappingDetail] PRIMARY KEY CLUSTERED ([CarrierHubUser], [cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CarrierHubIVRUserMappingDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierHubIVRUserMappingDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierHubIVRUserMappingDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierHubIVRUserMappingDetail] TO [public]
GO
