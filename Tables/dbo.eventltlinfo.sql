CREATE TABLE [dbo].[eventltlinfo]
(
[evt_number] [int] NOT NULL,
[option_number] [int] NULL CONSTRAINT [DF__eventltli__optio__55694A7A] DEFAULT ((0)),
[override_option_number] [int] NULL CONSTRAINT [DF__eventltli__overr__565D6EB3] DEFAULT ((0)),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[override_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[door_number] [int] NULL CONSTRAINT [DF__eventltli__door___575192EC] DEFAULT ((0)),
[override_door_number] [int] NULL CONSTRAINT [DF__eventltli__overr__5845B725] DEFAULT ((0)),
[unit_qtr] [int] NULL CONSTRAINT [DF__eventltli__unit___5939DB5E] DEFAULT ((0)),
[unit_pos] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__eventltli__unit___5A2DFF97] DEFAULT (''),
[plan_status] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__eventltli__plan___5B2223D0] DEFAULT (''),
[ref_evt_number] [int] NULL CONSTRAINT [DF__eventltli__ref_e__5C164809] DEFAULT ((0)),
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[eventltlinfo] ADD CONSTRAINT [PK__eventltl__00774C8958BDCF6C] PRIMARY KEY CLUSTERED ([evt_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[eventltlinfo] TO [public]
GO
GRANT INSERT ON  [dbo].[eventltlinfo] TO [public]
GO
GRANT REFERENCES ON  [dbo].[eventltlinfo] TO [public]
GO
GRANT SELECT ON  [dbo].[eventltlinfo] TO [public]
GO
GRANT UPDATE ON  [dbo].[eventltlinfo] TO [public]
GO
