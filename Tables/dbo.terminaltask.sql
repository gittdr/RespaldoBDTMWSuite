CREATE TABLE [dbo].[terminaltask]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tsk_type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tsk_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tsk_comment] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[src_door_number] [int] NULL CONSTRAINT [DF__terminalt__src_d__286199D9] DEFAULT ((0)),
[dst_door_number] [int] NULL CONSTRAINT [DF__terminalt__dst_d__2955BE12] DEFAULT ((0)),
[src_zone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminalt__src_z__2A49E24B] DEFAULT (''),
[dest_zone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminalt__dest___2B3E0684] DEFAULT (''),
[tsk_priority] [int] NULL CONSTRAINT [DF__terminalt__tsk_p__2C322ABD] DEFAULT ((0)),
[tsk_requested] [datetime] NULL,
[tsk_accepted] [datetime] NULL,
[tsk_started] [datetime] NULL,
[tsk_completed] [datetime] NULL,
[tsk_requested_usr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tsk_accepted_usr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mfh_number] [int] NULL CONSTRAINT [DF__terminalt__mfh_n__2D264EF6] DEFAULT ((0)),
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[terminaltask] ADD CONSTRAINT [PK__terminal__3213E83F22659C43] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[terminaltask] TO [public]
GO
GRANT INSERT ON  [dbo].[terminaltask] TO [public]
GO
GRANT REFERENCES ON  [dbo].[terminaltask] TO [public]
GO
GRANT SELECT ON  [dbo].[terminaltask] TO [public]
GO
GRANT UPDATE ON  [dbo].[terminaltask] TO [public]
GO
