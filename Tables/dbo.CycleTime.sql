CREATE TABLE [dbo].[CycleTime]
(
[CycleTimeId] [int] NOT NULL IDENTITY(1, 1),
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[version] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Type] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompanyId] [int] NULL,
[EventDate] [datetime] NULL,
[DriverId] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DriverName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VehicleNumber] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShippingInfo] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrailerNumber] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoDrivers] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataEndDate] [datetime] NULL,
[LastDutyStatus] [int] NULL,
[LastDutyStatusAddlInfo] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastDutyStatusChangeDate] [datetime] NULL,
[CurrentHoSRegulation] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DrivingSecondsToday] [int] NULL,
[OnDutySecondsToday] [int] NULL,
[sbSecondsToday] [int] NULL,
[OffDutySecondsToday] [int] NULL,
[DrivingSecsYesterday] [int] NULL,
[OnDutySecsYesterday] [int] NULL,
[sbSecsYesterday] [int] NULL,
[OffDutySecsYesterday] [int] NULL,
[ModifiedLast] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CycleTime] ADD CONSTRAINT [PK_dbo.CycleTime] PRIMARY KEY CLUSTERED ([CycleTimeId]) ON [PRIMARY]
GO
