CREATE TABLE [dbo].[meterhistory]
(
[mh_unittype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mh_unitnumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mh_reading] [int] NOT NULL,
[mh_units] [varbinary] (6) NOT NULL,
[mh_date] [datetime] NOT NULL,
[timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[meterhistory] TO [public]
GO
GRANT INSERT ON  [dbo].[meterhistory] TO [public]
GO
GRANT REFERENCES ON  [dbo].[meterhistory] TO [public]
GO
GRANT SELECT ON  [dbo].[meterhistory] TO [public]
GO
GRANT UPDATE ON  [dbo].[meterhistory] TO [public]
GO
