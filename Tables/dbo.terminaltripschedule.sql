CREATE TABLE [dbo].[terminaltripschedule]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[manifest_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[route_id] [int] NULL CONSTRAINT [DF__terminalt__route__32DF284C] DEFAULT ((0)),
[sched_description] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[monday_serv] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminalt__monda__33D34C85] DEFAULT ('Y'),
[tuesday_serv] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminalt__tuesd__34C770BE] DEFAULT ('Y'),
[wednesday_serv] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminalt__wedne__35BB94F7] DEFAULT ('Y'),
[thursday_serv] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminalt__thurs__36AFB930] DEFAULT ('Y'),
[friday_serv] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminalt__frida__37A3DD69] DEFAULT ('Y'),
[saturday_serv] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminalt__satur__389801A2] DEFAULT ('N'),
[sunday_serv] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminalt__sunda__398C25DB] DEFAULT ('N'),
[is_active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminalt__is_ac__3A804A14] DEFAULT ('Y'),
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[terminaltripschedule] ADD CONSTRAINT [PK__terminal__3213E83FD425A40C] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[terminaltripschedule] TO [public]
GO
GRANT INSERT ON  [dbo].[terminaltripschedule] TO [public]
GO
GRANT REFERENCES ON  [dbo].[terminaltripschedule] TO [public]
GO
GRANT SELECT ON  [dbo].[terminaltripschedule] TO [public]
GO
GRANT UPDATE ON  [dbo].[terminaltripschedule] TO [public]
GO
