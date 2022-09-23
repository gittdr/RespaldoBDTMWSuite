CREATE TABLE [dbo].[trip_modification_log]
(
[ord_hdrnumber] [int] NOT NULL,
[stp_number] [int] NOT NULL,
[tml_date] [datetime] NOT NULL,
[tml_event] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_event] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tml_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tml_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tml_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tml_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_sequence] [int] NULL,
[stp_reftype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_number] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_subcompany] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tml_orderby] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_schdtearliest] [datetime] NULL,
[stp_schdtlatest] [datetime] NULL,
[stp_arrivaldate] [datetime] NULL,
[stp_departuredate] [datetime] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [tml_primary] ON [dbo].[trip_modification_log] ([ord_hdrnumber], [stp_number], [tml_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trip_modification_log] TO [public]
GO
GRANT INSERT ON  [dbo].[trip_modification_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[trip_modification_log] TO [public]
GO
GRANT SELECT ON  [dbo].[trip_modification_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[trip_modification_log] TO [public]
GO
