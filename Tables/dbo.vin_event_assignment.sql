CREATE TABLE [dbo].[vin_event_assignment]
(
[vea_id] [int] NOT NULL IDENTITY(1, 1),
[vea_creation_dt] [datetime] NOT NULL,
[vea_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[vea_event_type] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[vea_event_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[vea_event_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[vin_event_assignment] ADD CONSTRAINT [dk_vea_cmp_id] PRIMARY KEY NONCLUSTERED ([vea_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [dk_vea_event_code] ON [dbo].[vin_event_assignment] ([vea_event_code]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [dk_vea_event_type] ON [dbo].[vin_event_assignment] ([vea_event_type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[vin_event_assignment] TO [public]
GO
GRANT INSERT ON  [dbo].[vin_event_assignment] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vin_event_assignment] TO [public]
GO
GRANT SELECT ON  [dbo].[vin_event_assignment] TO [public]
GO
GRANT UPDATE ON  [dbo].[vin_event_assignment] TO [public]
GO
