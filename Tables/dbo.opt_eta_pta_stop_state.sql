CREATE TABLE [dbo].[opt_eta_pta_stop_state]
(
[id] [bigint] NOT NULL,
[truck_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[arrived_time] [datetime] NULL,
[city] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delay] [numeric] (6, 1) NULL,
[departed_time] [datetime] NULL,
[early_time] [datetime] NULL,
[eta] [datetime] NULL,
[etd] [datetime] NULL,
[hours_late] [numeric] (6, 1) NULL,
[is_late] [bit] NULL,
[late_time] [datetime] NULL,
[load_id] [int] NULL,
[postal] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sequence] [bigint] NULL,
[state] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stop_id] [int] NULL,
[updated] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[opt_eta_pta_stop_state] ADD CONSTRAINT [pk_opt_eta_pta_stop_state] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_opt_eta_pta_stop_state_stop_id] ON [dbo].[opt_eta_pta_stop_state] ([stop_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_opt_eta_pta_stop_state_truck_id] ON [dbo].[opt_eta_pta_stop_state] ([truck_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[opt_eta_pta_stop_state] TO [public]
GO
GRANT INSERT ON  [dbo].[opt_eta_pta_stop_state] TO [public]
GO
GRANT REFERENCES ON  [dbo].[opt_eta_pta_stop_state] TO [public]
GO
GRANT SELECT ON  [dbo].[opt_eta_pta_stop_state] TO [public]
GO
GRANT UPDATE ON  [dbo].[opt_eta_pta_stop_state] TO [public]
GO
