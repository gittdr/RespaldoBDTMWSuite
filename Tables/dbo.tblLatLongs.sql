CREATE TABLE [dbo].[tblLatLongs]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Unit] [int] NULL,
[DateAndTime] [datetime] NULL,
[Lat] [float] NULL,
[Long] [float] NULL,
[Remark] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatePS] [bit] NOT NULL,
[Quality] [int] NULL,
[Landmark] [int] NULL,
[Miles] [real] NULL,
[Direction] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts] [timestamp] NULL,
[CityName] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NearestLargeCityName] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NearestLargeCityState] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NearestLargeCityZip] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NearestLargeCityDirection] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NearestLargeCityMiles] [int] NULL,
[VehicleIgnition] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateDisp] [int] NULL CONSTRAINT [DF__tblLatLon__Updat__5B78929E] DEFAULT (0),
[Odometer] [int] NULL,
[TripStatus] [int] NULL,
[odometer2] [int] NULL,
[speed] [int] NULL,
[speed2] [int] NULL,
[heading] [float] NULL,
[gps_type] [int] NULL,
[gps_miles] [float] NULL,
[fuel_meter] [float] NULL,
[idle_meter] [int] NULL,
[AssociatedMsgSN] [int] NULL,
[ExtraData01] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraData02] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraData03] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraData04] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraData05] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraData06] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraData07] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraData08] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraData09] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraData10] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraData11] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraData12] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraData13] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraData14] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraData15] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraData16] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraData17] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraData18] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraData19] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraData20] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATUS] [int] NULL,
[StatusReason] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CheckCallNumber] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblLatLongs] ADD CONSTRAINT [pk_tbllatlongs] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tblLatLongsXfr] ON [dbo].[tblLatLongs] ([DateAndTime], [UpdateDisp], [SN]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UnitID_DateAndTime] ON [dbo].[tblLatLongs] ([Unit], [DateAndTime]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tblLatLongs_Unit_Status] ON [dbo].[tblLatLongs] ([Unit], [STATUS]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblLatLongs] ADD CONSTRAINT [FK__Temporary__Landm__50DB089A] FOREIGN KEY ([Landmark]) REFERENCES [dbo].[tblLandmarks] ([SN])
GO
ALTER TABLE [dbo].[tblLatLongs] ADD CONSTRAINT [FK__TemporaryU__Unit__4FE6E461] FOREIGN KEY ([Unit]) REFERENCES [dbo].[tblCabUnits] ([SN])
GO
GRANT DELETE ON  [dbo].[tblLatLongs] TO [public]
GO
GRANT INSERT ON  [dbo].[tblLatLongs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblLatLongs] TO [public]
GO
GRANT SELECT ON  [dbo].[tblLatLongs] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblLatLongs] TO [public]
GO
