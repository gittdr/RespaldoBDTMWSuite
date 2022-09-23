CREATE TABLE [dbo].[TMSEvents]
(
[EventType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShortName] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LongName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsPickup] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsDrop] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsXDock] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSEvents] ADD CONSTRAINT [PK_TMSEvents] PRIMARY KEY CLUSTERED ([EventType]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMSEvents] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSEvents] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSEvents] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSEvents] TO [public]
GO
