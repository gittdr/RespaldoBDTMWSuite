CREATE TABLE [dbo].[terminaldoor]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[door_number] [int] NULL CONSTRAINT [DF__terminald__door___1BFBC2F4] DEFAULT ((0)),
[door_description] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dock_zone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminald__dock___1CEFE72D] DEFAULT (''),
[staging_area] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminald__stagi__1DE40B66] DEFAULT (''),
[mfh_number] [int] NULL,
[unit_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[allow_strip] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminald__allow__1ED82F9F] DEFAULT ('Y'),
[allow_stack] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminald__allow__1FCC53D8] DEFAULT ('Y'),
[allow_pd] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminald__allow__20C07811] DEFAULT ('Y'),
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[terminaldoor] ADD CONSTRAINT [PK__terminal__3213E83F53484239] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [termdoor_door] ON [dbo].[terminaldoor] ([cmp_id], [door_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[terminaldoor] TO [public]
GO
GRANT INSERT ON  [dbo].[terminaldoor] TO [public]
GO
GRANT REFERENCES ON  [dbo].[terminaldoor] TO [public]
GO
GRANT SELECT ON  [dbo].[terminaldoor] TO [public]
GO
GRANT UPDATE ON  [dbo].[terminaldoor] TO [public]
GO
