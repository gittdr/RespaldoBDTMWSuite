CREATE TABLE [dbo].[terminaltripschedule_legs]
(
[schedule_id] [int] NOT NULL,
[leg_seq] [int] NOT NULL,
[sched_dep_time] [datetime] NULL,
[cmp_id_start] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_id_end] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[hub_1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub_2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub_3] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub_4] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub_5] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub_6] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub_7] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub_8] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub_9] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[default_driver] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[default_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__terminalt__INS_T__78BE9E6B] DEFAULT (getdate()),
[DW_TIMESTAMP] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[terminaltripschedule_legs] ADD CONSTRAINT [PK__terminal__C6ED5D1E3BC2C83C] PRIMARY KEY CLUSTERED ([schedule_id], [leg_seq]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [terminaltripschedule_legs_INS_TIMESTAMP] ON [dbo].[terminaltripschedule_legs] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[terminaltripschedule_legs] TO [public]
GO
GRANT INSERT ON  [dbo].[terminaltripschedule_legs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[terminaltripschedule_legs] TO [public]
GO
GRANT SELECT ON  [dbo].[terminaltripschedule_legs] TO [public]
GO
GRANT UPDATE ON  [dbo].[terminaltripschedule_legs] TO [public]
GO
