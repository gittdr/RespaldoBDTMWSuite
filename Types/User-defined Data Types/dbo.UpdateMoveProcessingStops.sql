CREATE TYPE [dbo].[UpdateMoveProcessingStops] AS TABLE
(
[stp_number] [int] NOT NULL,
[mov_number] [int] NULL,
[lgh_number] [int] NULL,
[ord_hdrnumber] [int] NULL,
[stp_mfh_sequence] [int] NULL,
[stp_event] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_arrivaldate] [datetime] NULL,
[stp_departuredate] [datetime] NULL,
[stp_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_departure_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_lgh_mileage_mtid] [int] NULL,
[evt_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED ([stp_number])
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[UpdateMoveProcessingStops] TO [public]
GO
