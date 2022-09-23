CREATE TABLE [dbo].[tariffkeyrevall]
(
[tkr_id] [int] NOT NULL IDENTITY(1, 1),
[tkr_drop_stop] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tkr_pickup_stop] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tkr_split_first_segment_origin] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tkr_split_first_segment_dest] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tkr_ord_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tkr_ord_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tkr_ord_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tkr_ord_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tkr_eventcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tkr_event_loadstatus] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[thr_id] [int] NOT NULL,
[tkr_created_date] [datetime] NOT NULL,
[tkr_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tkr_modified_date] [datetime] NOT NULL,
[tkr_modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tkr_startdate] [datetime] NULL,
[tkr_enddate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tariffkeyrevall] ADD CONSTRAINT [pk_tariffkeyrevall_id] PRIMARY KEY CLUSTERED ([tkr_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tariffkeyrevall] TO [public]
GO
GRANT INSERT ON  [dbo].[tariffkeyrevall] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tariffkeyrevall] TO [public]
GO
GRANT SELECT ON  [dbo].[tariffkeyrevall] TO [public]
GO
GRANT UPDATE ON  [dbo].[tariffkeyrevall] TO [public]
GO
