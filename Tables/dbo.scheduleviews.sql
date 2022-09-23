CREATE TABLE [dbo].[scheduleviews]
(
[scv_id] [int] NOT NULL,
[scv_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_subcompany] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_company] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scv_lastfromdate] [datetime] NULL,
[scv_lasttodate] [datetime] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [scv_primary] ON [dbo].[scheduleviews] ([scv_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[scheduleviews] TO [public]
GO
GRANT INSERT ON  [dbo].[scheduleviews] TO [public]
GO
GRANT REFERENCES ON  [dbo].[scheduleviews] TO [public]
GO
GRANT SELECT ON  [dbo].[scheduleviews] TO [public]
GO
GRANT UPDATE ON  [dbo].[scheduleviews] TO [public]
GO
