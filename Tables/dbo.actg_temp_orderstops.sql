CREATE TABLE [dbo].[actg_temp_orderstops]
(
[sp_id] [int] NULL,
[ord_hdrnumber] [int] NULL,
[stp_number] [int] NULL,
[mov_number] [int] NULL,
[lgh_number] [int] NULL,
[stp_ord_mileage] [int] NULL,
[stp_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_loadstatus] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_sequence] [int] NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_event] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_eventcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_sequence] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[actg_temp_orderstops] TO [public]
GO
GRANT INSERT ON  [dbo].[actg_temp_orderstops] TO [public]
GO
GRANT REFERENCES ON  [dbo].[actg_temp_orderstops] TO [public]
GO
GRANT SELECT ON  [dbo].[actg_temp_orderstops] TO [public]
GO
GRANT UPDATE ON  [dbo].[actg_temp_orderstops] TO [public]
GO
