CREATE TABLE [dbo].[sv_import_miles_by_state_audit]
(
[audit_id] [int] NOT NULL IDENTITY(1, 1),
[audit_user] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[audit_dttm] [datetime] NOT NULL,
[audit_action] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[imp_id] [int] NOT NULL,
[dist_center] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unload_id] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[segment_start_date] [datetime] NULL,
[segment_end_date] [datetime] NULL,
[trip_date] [datetime] NULL,
[tractor_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trip_num] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state_code] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[odometer] [decimal] (19, 4) NULL,
[tot_distance] [decimal] (19, 4) NULL,
[laden_distance] [decimal] (19, 4) NULL,
[fuel_used] [decimal] (19, 4) NULL,
[toll] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[weight] [decimal] (19, 4) NULL,
[road] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[source_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[sv_import_miles_by_state_audit] ADD CONSTRAINT [pk_sv_import_miles_by_state_audit] PRIMARY KEY CLUSTERED ([audit_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[sv_import_miles_by_state_audit] TO [public]
GO
GRANT INSERT ON  [dbo].[sv_import_miles_by_state_audit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[sv_import_miles_by_state_audit] TO [public]
GO
GRANT SELECT ON  [dbo].[sv_import_miles_by_state_audit] TO [public]
GO
GRANT UPDATE ON  [dbo].[sv_import_miles_by_state_audit] TO [public]
GO
