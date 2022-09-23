CREATE TABLE [dbo].[CarrierLTLServiceZone]
(
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Zip] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ServiceZone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OriginServiceLevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OriginExtraDays] [int] NOT NULL,
[DestinationServiceLevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DestinationExtraDays] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarrierLTLServiceZone] ADD CONSTRAINT [PK_CarrierLTLServiceZone] PRIMARY KEY CLUSTERED ([car_id], [Zip]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CarrierLTLServiceZone] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierLTLServiceZone] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierLTLServiceZone] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierLTLServiceZone] TO [public]
GO
