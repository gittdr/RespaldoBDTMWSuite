CREATE TABLE [dbo].[drivershiftevent]
(
[shift_event_id] [int] NOT NULL IDENTITY(1, 1),
[shift_id] [int] NOT NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[stp_event] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[stp_number] [int] NOT NULL,
[event_type] [int] NOT NULL,
[event_timestamp] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[drivershiftevent] ADD CONSTRAINT [PK__driversh__ECDD828CD7026B30] PRIMARY KEY CLUSTERED ([shift_event_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[drivershiftevent] TO [public]
GO
GRANT INSERT ON  [dbo].[drivershiftevent] TO [public]
GO
GRANT REFERENCES ON  [dbo].[drivershiftevent] TO [public]
GO
GRANT SELECT ON  [dbo].[drivershiftevent] TO [public]
GO
GRANT UPDATE ON  [dbo].[drivershiftevent] TO [public]
GO
