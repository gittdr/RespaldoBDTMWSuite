CREATE TABLE [dbo].[asset_ltl_info]
(
[unit_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[unit_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status_ts] [datetime] NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dock_zone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[door_number] [int] NULL CONSTRAINT [DF__asset_ltl__door___39C13005] DEFAULT ((0)),
[move_status] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[work_status] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowchgts] [timestamp] NOT NULL,
[move_task_id] [int] NULL,
[work_task_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[asset_ltl_info] ADD CONSTRAINT [PK__asset_lt__FAB11869A9E47159] PRIMARY KEY CLUSTERED ([unit_type], [unit_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[asset_ltl_info] TO [public]
GO
GRANT INSERT ON  [dbo].[asset_ltl_info] TO [public]
GO
GRANT REFERENCES ON  [dbo].[asset_ltl_info] TO [public]
GO
GRANT SELECT ON  [dbo].[asset_ltl_info] TO [public]
GO
GRANT UPDATE ON  [dbo].[asset_ltl_info] TO [public]
GO
