CREATE TABLE [dbo].[tblCheckcallXfc]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Tractor] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateAndTime] [datetime] NULL,
[Lat] [float] NULL,
[Long] [float] NULL,
[Miles] [real] NULL,
[Direction] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CityName] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Comments] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LargeComments] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VehicleIgnition] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
ALTER TABLE [dbo].[tblCheckcallXfc] ADD CONSTRAINT [PK_tblCheckcallXfc] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_tblCheckcallxfc_SN] ON [dbo].[tblCheckcallXfc] ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblCheckcallXfc] TO [public]
GO
GRANT INSERT ON  [dbo].[tblCheckcallXfc] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblCheckcallXfc] TO [public]
GO
GRANT SELECT ON  [dbo].[tblCheckcallXfc] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblCheckcallXfc] TO [public]
GO
