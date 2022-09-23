CREATE TABLE [dbo].[KaneTrips]
(
[ImpId] [int] NOT NULL IDENTITY(1, 1),
[KaneId] [int] NOT NULL,
[AllAuthors] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillTo] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C10FLAG] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C10PARM] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReasonStatus2ChLimit] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AuthorizationNumber16ChLimit] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Date] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PersonName16ChLimit] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StopNum] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Time] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Carrier] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TotalCost] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TotalCube] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ScheduledDeliveryDate] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TotalMileage] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddressNum1] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddressNum2] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[City] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C4DSTID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[State] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Zip] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TotalPallets] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ScheduledPickupDate] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TotalCases] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ConsolidationNumber] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C4TSTP] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TotalWeight] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Carrier2] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CommitCube] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CommitPallets] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CommitQuantity] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CommitWeight] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToCapacity] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[History] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[KaneCarrier] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[KaneCarrier2] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IfLoadShippedLightSelectReason] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NextNumber] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToCapacity2] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadStatus] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TripStatus] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TripStatus2] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TCDate] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Notes] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TmpTripNumber] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrailerSize] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TripType] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TStatus] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TUCDate] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReOpenedReason] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VICSNUM] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToCapacity3] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KaneTrips] ADD CONSTRAINT [PK_KaneTrips] PRIMARY KEY CLUSTERED ([ImpId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KaneTrips] ADD CONSTRAINT [FK_KaneTrips_KaneBatch] FOREIGN KEY ([KaneId]) REFERENCES [dbo].[KaneBatch] ([KaneId])
GO
GRANT DELETE ON  [dbo].[KaneTrips] TO [public]
GO
GRANT INSERT ON  [dbo].[KaneTrips] TO [public]
GO
GRANT SELECT ON  [dbo].[KaneTrips] TO [public]
GO
GRANT UPDATE ON  [dbo].[KaneTrips] TO [public]
GO
