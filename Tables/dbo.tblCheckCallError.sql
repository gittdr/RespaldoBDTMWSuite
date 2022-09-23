CREATE TABLE [dbo].[tblCheckCallError]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[DateAndTime] [datetime] NULL,
[DateInserted] [datetime] NULL,
[TruckSN] [int] NULL,
[Truck] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MctSN] [int] NULL,
[Driver] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_date] [datetime] NULL,
[lgh_number] [int] NULL,
[Lat] [float] NULL,
[Long] [float] NULL,
[City] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Direction] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Miles] [real] NULL,
[LargeCity] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LargeState] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LargeZip] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LargeDirection] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LargeMiles] [int] NULL,
[VehicleIgnition] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorNote] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Odometer] [int] NULL,
[odometer2] [int] NULL,
[speed] [int] NULL,
[speed2] [int] NULL,
[heading] [float] NULL,
[gps_type] [int] NULL,
[gps_miles] [float] NULL,
[fuel_meter] [float] NULL,
[idle_meter] [int] NULL,
[AssociatedMsgSN] [int] NULL,
[ckc_ExtraData01] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData02] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData03] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData04] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData05] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData06] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData07] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData08] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData09] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData10] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData11] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData12] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData13] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData14] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData15] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData16] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData17] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData18] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData19] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData20] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCheckCallError] ADD CONSTRAINT [PK_tbltblCheckCallError] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblCheckCallError] TO [public]
GO
GRANT INSERT ON  [dbo].[tblCheckCallError] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblCheckCallError] TO [public]
GO
GRANT SELECT ON  [dbo].[tblCheckCallError] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblCheckCallError] TO [public]
GO
