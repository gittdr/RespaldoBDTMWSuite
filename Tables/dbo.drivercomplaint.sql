CREATE TABLE [dbo].[drivercomplaint]
(
[mpp_id] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[drc_datereceived] [datetime] NOT NULL,
[drc_dateoccured] [datetime] NOT NULL,
[drc_company] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drc_city] [int] NULL,
[drc_location] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drc_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drc_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drc_drivercomments] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drc_receivedby] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drc_handledby] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drc_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[drc_source] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_id_date] ON [dbo].[drivercomplaint] ([mpp_id], [drc_dateoccured]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[drivercomplaint] TO [public]
GO
GRANT INSERT ON  [dbo].[drivercomplaint] TO [public]
GO
GRANT REFERENCES ON  [dbo].[drivercomplaint] TO [public]
GO
GRANT SELECT ON  [dbo].[drivercomplaint] TO [public]
GO
GRANT UPDATE ON  [dbo].[drivercomplaint] TO [public]
GO
