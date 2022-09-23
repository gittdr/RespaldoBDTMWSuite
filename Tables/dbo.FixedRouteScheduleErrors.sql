CREATE TABLE [dbo].[FixedRouteScheduleErrors]
(
[fre_id] [int] NOT NULL IDENTITY(1, 1),
[fre_route] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fre_start_date] [datetime] NULL,
[fre_error] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FixedRouteScheduleErrors] ADD CONSTRAINT [pk_fixedroutescheduleerrors_fre_id] PRIMARY KEY CLUSTERED ([fre_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_fixedroutescheduleerrors_composite] ON [dbo].[FixedRouteScheduleErrors] ([fre_route], [fre_start_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FixedRouteScheduleErrors] TO [public]
GO
GRANT INSERT ON  [dbo].[FixedRouteScheduleErrors] TO [public]
GO
GRANT REFERENCES ON  [dbo].[FixedRouteScheduleErrors] TO [public]
GO
GRANT SELECT ON  [dbo].[FixedRouteScheduleErrors] TO [public]
GO
GRANT UPDATE ON  [dbo].[FixedRouteScheduleErrors] TO [public]
GO
