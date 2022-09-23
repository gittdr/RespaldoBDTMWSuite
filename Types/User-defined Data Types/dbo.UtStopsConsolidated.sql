CREATE TYPE [dbo].[UtStopsConsolidated] AS TABLE
(
[stp_number] [int] NOT NULL,
[mov_number] [int] NULL,
[lgh_number] [int] NULL,
[ord_hdrnumber] [int] NULL,
[stp_mfh_sequence] [int] NULL,
[stp_sequence] [int] NULL,
[stp_event] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_arrivaldate] [datetime] NULL,
[stp_departuredate] [datetime] NULL,
[stp_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_departure_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_schdtearliest] [datetime] NULL,
[stp_schdtlatest] [datetime] NULL,
[stp_custpickupdate] [datetime] NULL,
[stp_custdeliverydate] [datetime] NULL,
[stp_eta] [datetime] NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_city] [int] NULL,
[stp_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_reasonlate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_reasonlate_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_reasonlate_depart] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_reasonlate_depart_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_podname] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_comment] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psh_number] [int] NULL,
[stp_detstatus] [int] NULL,
[last_updatedate] [datetime] NULL,
[last_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedatedepart] [datetime] NULL,
[last_updatebydepart] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_optimizationdate] [datetime] NULL,
[stp_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_reftype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_description] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_weight] [decimal] (12, 4) NULL,
[stp_weightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_count] [decimal] (10, 2) NULL,
[stp_countunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_volume] [decimal] (10, 4) NULL,
[stp_volumeunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_pallets_in] [decimal] (10, 2) NULL,
[stp_pallets_out] [decimal] (10, 2) NULL,
[skip_trigger] [int] NULL,
PRIMARY KEY CLUSTERED ([stp_number])
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[UtStopsConsolidated] TO [public]
GO
