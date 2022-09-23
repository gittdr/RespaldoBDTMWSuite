CREATE TABLE [dbo].[drivercalendarhistory]
(
[dch_id] [int] NOT NULL IDENTITY(1, 1),
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dch_sequence] [int] NOT NULL,
[dch_week] [datetime] NULL,
[dch_week1_dow] [int] NULL,
[dch_week1_starttime] [datetime] NULL,
[dch_week1_hours] [decimal] (4, 2) NULL,
[dch_week1_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dch_week2_dow] [int] NULL,
[dch_week2_starttime] [datetime] NULL,
[dch_week2_hours] [decimal] (4, 2) NULL,
[dch_week2_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dch_bid_dow] [int] NULL,
[dch_bid_starttime] [datetime] NULL,
[drc_bid_hours] [decimal] (4, 2) NULL,
[drc_bid_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dch_bid_hours] [decimal] (4, 2) NULL,
[dch_bid_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dch_week1_store] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dch_week1_route] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dch_week2_store] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dch_week2_route] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dch_bid_store] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dch_bid_route] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[drivercalendarhistory] TO [public]
GO
GRANT INSERT ON  [dbo].[drivercalendarhistory] TO [public]
GO
GRANT REFERENCES ON  [dbo].[drivercalendarhistory] TO [public]
GO
GRANT SELECT ON  [dbo].[drivercalendarhistory] TO [public]
GO
GRANT UPDATE ON  [dbo].[drivercalendarhistory] TO [public]
GO
