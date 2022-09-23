CREATE TYPE [dbo].[UtLegheaderConsolidated] AS TABLE
(
[lgh_number] [int] NULL,
[lgh_startdate] [datetime] NULL,
[lgh_outstatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_number_start] [int] NULL,
[cmp_id_start] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_id_end] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_endcity] [int] NULL,
[lgh_driver1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_driver2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_primary_trailer] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mov_number] [int] NULL,
[ord_hdrnumber] [int] NULL,
[lgh_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_primary_pup] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_dsp_date] [datetime] NULL,
[lgh_dispatchdate] [datetime] NULL,
[lgh_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_tm_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_204status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_booked_revtype1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_recommended_car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_204_tradingpartner] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_204validate] [int] NULL,
[lgh_other_status1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_other_status2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_number] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[UtLegheaderConsolidated] TO [public]
GO
