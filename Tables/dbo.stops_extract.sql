CREATE TABLE [dbo].[stops_extract]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[mov_number] [int] NULL,
[stp_sequence] [int] NULL,
[evt_driver1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_trailer1] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_trailer2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_refnum] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[route_date] [datetime] NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_arrivaldate] [datetime] NULL,
[stp_departuredate] [datetime] NULL,
[stp_lgh_mileage] [int] NULL,
[prev_stop_departure] [datetime] NULL,
[ord_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sent] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[confirmed] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[create_dt] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[stops_extract] ADD CONSTRAINT [PK__stops_extract__60375097] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[stops_extract] TO [public]
GO
GRANT INSERT ON  [dbo].[stops_extract] TO [public]
GO
GRANT REFERENCES ON  [dbo].[stops_extract] TO [public]
GO
GRANT SELECT ON  [dbo].[stops_extract] TO [public]
GO
GRANT UPDATE ON  [dbo].[stops_extract] TO [public]
GO
