CREATE TABLE [dbo].[opt_eta_pta_power_state]
(
[id] [bigint] NOT NULL,
[current_dispatched_load_id] [int] NULL,
[driver_1_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_1_is_home] [bit] NULL,
[driver_1_is_home_at_pta] [bit] NULL,
[driver_1_miles_to_home] [numeric] (6, 1) NULL,
[driver_1_miles_to_home_at_pta] [numeric] (6, 1) NULL,
[driver_2_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_2_is_home] [bit] NULL,
[driver_2_is_home_at_pta] [bit] NULL,
[driver_2_miles_to_home] [numeric] (6, 1) NULL,
[driver_2_miles_to_home_at_pta] [numeric] (6, 1) NULL,
[driver_1_hours_remaining_day_drive_at_pta] [numeric] (6, 1) NULL,
[driver_1_hours_remaining_day_duty_at_pta] [numeric] (6, 1) NULL,
[driver_1_hours_remaining_on_day_drive] [numeric] (6, 1) NULL,
[driver_1_hours_remaining_on_day_duty] [numeric] (6, 1) NULL,
[driver_1_hours_remaining_on_week] [numeric] (6, 1) NULL,
[driver_1_hours_remaining_week_at_pta] [numeric] (6, 1) NULL,
[driver_2_hours_remaining_day_drive_at_pta] [numeric] (6, 1) NULL,
[driver_2_hours_remaining_day_duty_at_pta] [numeric] (6, 1) NULL,
[driver_2_hours_remaining_on_day_drive] [numeric] (6, 1) NULL,
[driver_2_hours_remaining_on_day_duty] [numeric] (6, 1) NULL,
[driver_2_hours_remaining_on_week] [numeric] (6, 1) NULL,
[driver_2_hours_remaining_week_at_pta] [numeric] (6, 1) NULL,
[hours_late] [numeric] (6, 1) NULL,
[is_dispatched] [bit] NULL,
[is_late_for_any_stop] [bit] NULL,
[last_ping_date] [datetime] NULL,
[power_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pta] [datetime] NULL,
[pta_city] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pta_country] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pta_postal] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pta_state] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updated] [datetime] NULL,
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hos_source] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_opt_eta_pta_power_state]
ON [dbo].[opt_eta_pta_power_state] FOR INSERT, UPDATE
AS

SET NOCOUNT ON

UPDATE	opt_eta_pta_power_state
   SET	car_id = ISNULL(l.lgh_carrier, 'UNKNOWN')
  FROM	opt_eta_pta_power_state ps
			INNER JOIN inserted i ON i.id = ps.id
			LEFT OUTER JOIN legheader l ON l.lgh_number = ps.current_dispatched_load_id

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[opt_eta_pta_power_state] ADD CONSTRAINT [pk_opt_eta_pta_power_state] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_power_state_car_id_load_id] ON [dbo].[opt_eta_pta_power_state] ([car_id], [current_dispatched_load_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [uk_opt_eta_pta_power_state_power_id] ON [dbo].[opt_eta_pta_power_state] ([power_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[opt_eta_pta_power_state] TO [public]
GO
GRANT INSERT ON  [dbo].[opt_eta_pta_power_state] TO [public]
GO
GRANT REFERENCES ON  [dbo].[opt_eta_pta_power_state] TO [public]
GO
GRANT SELECT ON  [dbo].[opt_eta_pta_power_state] TO [public]
GO
GRANT UPDATE ON  [dbo].[opt_eta_pta_power_state] TO [public]
GO
