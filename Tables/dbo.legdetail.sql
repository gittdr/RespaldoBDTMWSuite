CREATE TABLE [dbo].[legdetail]
(
[lgd_number] [int] NOT NULL,
[lgh_number] [int] NOT NULL,
[lgd_startcity] [int] NULL,
[lgd_startstate] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgd_endcity] [int] NULL,
[lgd_endstate] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgd_startregion] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgd_endregion] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgd_startdate] [datetime] NOT NULL,
[lgd_enddate] [datetime] NULL,
[lgd_odometerstart] [int] NULL,
[lgd_odometerend] [int] NULL,
[lgd_startlegnumber] [int] NULL,
[lgd_endlegnumber] [int] NULL,
[lgd_mileagetype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [leg] ON [dbo].[legdetail] ([lgd_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [date] ON [dbo].[legdetail] ([lgd_startdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [legheader] ON [dbo].[legdetail] ([lgh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[legdetail] TO [public]
GO
GRANT INSERT ON  [dbo].[legdetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[legdetail] TO [public]
GO
GRANT SELECT ON  [dbo].[legdetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[legdetail] TO [public]
GO
