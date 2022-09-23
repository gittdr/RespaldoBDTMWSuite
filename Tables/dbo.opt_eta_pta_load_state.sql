CREATE TABLE [dbo].[opt_eta_pta_load_state]
(
[truck_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eta_to_first_pickup] [datetime] NULL,
[etd_from_last_delivery] [datetime] NULL,
[first_pickup_city] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[first_pickup_country] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[first_pickup_postal] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[first_pickup_state] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hours_late] [numeric] (6, 1) NULL,
[driver_1_hours_remaining_on_day_drive_at_i_pta] [numeric] (6, 1) NULL,
[driver_1_hours_remaining_on_day_duty_at_i_pta] [numeric] (6, 1) NULL,
[driver_1_hours_remaining_on_week_at_i_pta] [numeric] (6, 1) NULL,
[driver_2_hours_remaining_on_day_drive_at_i_pta] [numeric] (6, 1) NULL,
[driver_2_hours_remaining_on_day_duty_at_i_pta] [numeric] (6, 1) NULL,
[driver_2_hours_remaining_on_week_at_i_pta] [numeric] (6, 1) NULL,
[hours_until_pickup_late] [numeric] (6, 1) NULL,
[i_pta] [datetime] NULL,
[i_pta_city] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[i_pta_country] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[i_pta_postal] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[i_pta_state] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_late_for_any_stop] [bit] NULL,
[last_delivery_city] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_delivery_country] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_delivery_postal] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_delivery_state] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[load_id] [int] NOT NULL,
[order_id] [int] NULL,
[rule_set] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[total_delay] [numeric] (6, 1) NULL,
[updated] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[opt_eta_pta_load_state] ADD CONSTRAINT [pk_opt_eta_pta_load_state] PRIMARY KEY CLUSTERED ([load_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_opt_eta_pta_load_state_order_id] ON [dbo].[opt_eta_pta_load_state] ([order_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_opt_eta_pta_load_state_truck_id] ON [dbo].[opt_eta_pta_load_state] ([truck_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[opt_eta_pta_load_state] TO [public]
GO
GRANT INSERT ON  [dbo].[opt_eta_pta_load_state] TO [public]
GO
GRANT REFERENCES ON  [dbo].[opt_eta_pta_load_state] TO [public]
GO
GRANT SELECT ON  [dbo].[opt_eta_pta_load_state] TO [public]
GO
GRANT UPDATE ON  [dbo].[opt_eta_pta_load_state] TO [public]
GO
