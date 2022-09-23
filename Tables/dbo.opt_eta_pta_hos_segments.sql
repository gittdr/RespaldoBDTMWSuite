CREATE TABLE [dbo].[opt_eta_pta_hos_segments]
(
[id] [bigint] NOT NULL,
[begin_segment_time] [datetime] NULL,
[driver_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[duration_in_hours] [numeric] (6, 1) NULL,
[end_of_last_break] [datetime] NULL,
[end_of_last_reset] [datetime] NULL,
[end_segment_time] [datetime] NULL,
[hours_driven_since_last_break] [numeric] (6, 1) NULL,
[hours_driver_since_last_reset] [numeric] (6, 1) NULL,
[hours_remaining_on_day_drive] [numeric] (6, 1) NULL,
[hours_remaining_on_day_duty] [numeric] (6, 1) NULL,
[hours_remaining_on_week] [numeric] (6, 1) NULL,
[rule_set] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[segment_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stop_id] [int] NULL,
[truck_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[updated] [datetime] NULL,
[weekly_hrs_worked_since_last_break_or_reset] [numeric] (6, 1) NULL,
[work_status] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[opt_eta_pta_hos_segments] ADD CONSTRAINT [pk_opt_eta_pta_hos_segments] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_opt_eta_pta_hos_segments_truck_id] ON [dbo].[opt_eta_pta_hos_segments] ([truck_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[opt_eta_pta_hos_segments] TO [public]
GO
GRANT INSERT ON  [dbo].[opt_eta_pta_hos_segments] TO [public]
GO
GRANT REFERENCES ON  [dbo].[opt_eta_pta_hos_segments] TO [public]
GO
GRANT SELECT ON  [dbo].[opt_eta_pta_hos_segments] TO [public]
GO
GRANT UPDATE ON  [dbo].[opt_eta_pta_hos_segments] TO [public]
GO
