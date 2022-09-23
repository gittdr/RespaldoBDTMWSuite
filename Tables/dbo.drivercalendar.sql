CREATE TABLE [dbo].[drivercalendar]
(
[drc_id] [int] NOT NULL IDENTITY(1, 1),
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[drc_sequence] [int] NOT NULL,
[drc_week] [datetime] NULL,
[drc_week1_dow] [int] NULL,
[drc_week1_starttime] [datetime] NULL,
[drc_week1_hours] [decimal] (4, 2) NULL,
[drc_week1_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drc_week2_dow] [int] NULL,
[drc_week2_starttime] [datetime] NULL,
[drc_week2_hours] [decimal] (4, 2) NULL,
[drc_week2_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drc_bid_dow] [int] NULL,
[drc_bid_starttime] [datetime] NULL,
[drc_bid_hours] [decimal] (4, 2) NULL,
[drc_bid_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drc_week1_store] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drc_week1_route] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drc_week2_store] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drc_week2_route] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drc_bid_store] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drc_bid_route] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [pk_drivercalendar] ON [dbo].[drivercalendar] ([drc_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_drivercalendar_mppid] ON [dbo].[drivercalendar] ([mpp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[drivercalendar] TO [public]
GO
GRANT INSERT ON  [dbo].[drivercalendar] TO [public]
GO
GRANT REFERENCES ON  [dbo].[drivercalendar] TO [public]
GO
GRANT SELECT ON  [dbo].[drivercalendar] TO [public]
GO
GRANT UPDATE ON  [dbo].[drivercalendar] TO [public]
GO
