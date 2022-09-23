CREATE TABLE [dbo].[driverobservation]
(
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dro_observationdt] [datetime] NOT NULL,
[dro_city] [int] NULL,
[dro_state] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dro_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dro_points] [smallint] NULL,
[dro_seatbelt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dro_uniform] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dro_security] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dro_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dro_observedby] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dro_headlight] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dro_drivercomments] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[road_conditions] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_dro_drvdt] ON [dbo].[driverobservation] ([mpp_id], [dro_observationdt]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[driverobservation] TO [public]
GO
GRANT INSERT ON  [dbo].[driverobservation] TO [public]
GO
GRANT REFERENCES ON  [dbo].[driverobservation] TO [public]
GO
GRANT SELECT ON  [dbo].[driverobservation] TO [public]
GO
GRANT UPDATE ON  [dbo].[driverobservation] TO [public]
GO
