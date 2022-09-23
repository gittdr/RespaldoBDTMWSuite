CREATE TABLE [dbo].[TMSShipment]
(
[ShipId] [int] NOT NULL IDENTITY(1, 1),
[Account] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Mode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceLevel] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceDays] [int] NULL,
[Carrier] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferenceValue1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferenceValue2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type4] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type5] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type6] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type7] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type8] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type9] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type10] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispatchNumber] [int] NULL,
[ShipmentNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransitID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSShipment] ADD CONSTRAINT [PK_TMSShipment] PRIMARY KEY CLUSTERED ([ShipId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DX_TMSShipment_DispatchNumber] ON [dbo].[TMSShipment] ([DispatchNumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [UX_ShipmentNumber] ON [dbo].[TMSShipment] ([ShipmentNumber]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSShipment] ADD CONSTRAINT [FK_TMSTransit_TMSShipment] FOREIGN KEY ([TransitID]) REFERENCES [dbo].[TMSTransit] ([TransitID])
GO
GRANT DELETE ON  [dbo].[TMSShipment] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSShipment] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSShipment] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSShipment] TO [public]
GO
