CREATE TABLE [dbo].[terminalroute]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[route_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[route_description] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[door_number] [int] NULL CONSTRAINT [DF__terminalr__door___239CE4BC] DEFAULT ((0)),
[pickup_cutoff] [datetime] NULL,
[pickup_time_to_dock] [int] NULL CONSTRAINT [DF__terminalr__picku__249108F5] DEFAULT ((0)),
[pre_trip_time] [int] NULL CONSTRAINT [DF__terminalr__pre_t__25852D2E] DEFAULT ((0)),
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[terminalroute] ADD CONSTRAINT [PK__terminal__3213E83F2B4604AB] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[terminalroute] TO [public]
GO
GRANT INSERT ON  [dbo].[terminalroute] TO [public]
GO
GRANT REFERENCES ON  [dbo].[terminalroute] TO [public]
GO
GRANT SELECT ON  [dbo].[terminalroute] TO [public]
GO
GRANT UPDATE ON  [dbo].[terminalroute] TO [public]
GO
