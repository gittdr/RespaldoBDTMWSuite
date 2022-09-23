CREATE TABLE [dbo].[eventcustom]
(
[evt_number] [int] NOT NULL,
[evtc_row_type] [int] NOT NULL,
[evtc_trip_number] [int] NULL,
[evtc_delay_time_edit_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evtc_delay_time] [decimal] (13, 4) NULL,
[evtc_delay_time_rounded] [decimal] (13, 4) NULL,
[evtc_delay_time_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evtc_tolls] [money] NULL,
[evtc_tolls_edit_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evtc_actual_miles] [int] NULL,
[evtc_actual_miles_adj] [int] NULL,
[evtc_standard_trip_miles] [int] NULL,
[evtc_standard_trip_miles_adj] [int] NULL,
[evtc_zone] [int] NULL,
[evtc_bh_zone] [int] NULL,
[evtc_pu_dr_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evtc_delivery_hours_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evtc_sequence] [int] NULL,
[evtc_delivery_time] [decimal] (13, 4) NULL,
[evtc_delivery_time_rounded] [decimal] (13, 4) NULL,
[bdd_id] [int] NULL,
[evtc_created_date] [datetime] NOT NULL,
[evtc_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[evtc_modified_date] [datetime] NOT NULL,
[evtc_modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[evtc_actual_miles_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evtc_standard_trip_miles_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evtc_zone_amount] [money] NULL,
[evtc_bh_zone_amount] [money] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[eventcustom] ADD CONSTRAINT [PK_eventcustom] PRIMARY KEY NONCLUSTERED ([evt_number], [evtc_row_type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_bdd_id] ON [dbo].[eventcustom] ([bdd_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[eventcustom] TO [public]
GO
GRANT INSERT ON  [dbo].[eventcustom] TO [public]
GO
GRANT REFERENCES ON  [dbo].[eventcustom] TO [public]
GO
GRANT SELECT ON  [dbo].[eventcustom] TO [public]
GO
GRANT UPDATE ON  [dbo].[eventcustom] TO [public]
GO
