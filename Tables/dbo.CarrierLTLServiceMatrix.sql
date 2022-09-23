CREATE TABLE [dbo].[CarrierLTLServiceMatrix]
(
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OriginServiceZone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DestinationServiceZone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Days] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarrierLTLServiceMatrix] ADD CONSTRAINT [PK_CarrierLTLServiceMatrix] PRIMARY KEY CLUSTERED ([car_id], [OriginServiceZone], [DestinationServiceZone]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CarrierLTLServiceMatrix] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierLTLServiceMatrix] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierLTLServiceMatrix] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierLTLServiceMatrix] TO [public]
GO
