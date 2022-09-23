CREATE TABLE [dbo].[CompanyScheduleDetail]
(
[csd_id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[csd_ReschedulePenalty] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[csd_ScheduleContactRequired] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[csd_AppointmentRequired] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[csd_LastUpdateBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[csd_LastUpdateOn] [datetime] NOT NULL,
[csd_ShipperAppointmentRequired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csd_ConsigneeAppointmentRequired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csd_DefaultStartTimeAdjustment] [int] NULL,
[csd_DefaultEndTimeAdjustment] [int] NULL,
[csd_ReschedulePenaltyAmount] [money] NULL,
[csd_RescheduleContactRequired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csd_ReasonLateReqdThreshold] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_CompanyScheduleDetail_cmp_id] ON [dbo].[CompanyScheduleDetail] ([cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CompanyScheduleDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[CompanyScheduleDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[CompanyScheduleDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[CompanyScheduleDetail] TO [public]
GO
