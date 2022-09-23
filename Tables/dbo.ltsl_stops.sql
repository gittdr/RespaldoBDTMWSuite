CREATE TABLE [dbo].[ltsl_stops]
(
[ord_hdrnumber] [int] NOT NULL,
[stp_number] [int] NOT NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_region1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_region2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_region3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_city] [int] NOT NULL,
[stp_state] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_schdtearliest] [datetime] NULL,
[stp_origschdt] [datetime] NULL,
[stp_arrivaldate] [datetime] NULL,
[stp_departuredate] [datetime] NULL,
[stp_reasonlate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_schdtlatest] [datetime] NULL,
[lgh_number] [int] NULL,
[mfh_number] [int] NULL,
[stp_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_paylegpt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shp_hdrnumber] [int] NULL,
[stp_sequence] [int] NULL,
[stp_region4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_lgh_sequence] [int] NULL,
[trl_id] [char] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_mfh_sequence] [int] NULL,
[stp_event] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_mfh_position] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_lgh_position] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_mfh_status] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_lgh_status] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_ord_mileage] [int] NULL,
[stp_lgh_mileage] [int] NULL,
[stp_mfh_mileage] [int] NULL,
[mov_number] [int] NULL,
[timestamp] [binary] (8) NULL,
[stp_loadstatus] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_weight] [float] NULL,
[stp_weightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_count] [smallint] NULL,
[stp_countunit] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_comment] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_reftype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_reasonlate_depart] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_screenmode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[skip_trigger] [tinyint] NULL,
[stp_volume] [float] NULL,
[stp_volumeunit] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_dispatched_sequence] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ltsl_stops] TO [public]
GO
GRANT INSERT ON  [dbo].[ltsl_stops] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ltsl_stops] TO [public]
GO
GRANT SELECT ON  [dbo].[ltsl_stops] TO [public]
GO
GRANT UPDATE ON  [dbo].[ltsl_stops] TO [public]
GO
