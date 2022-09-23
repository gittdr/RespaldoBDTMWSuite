CREATE TABLE [dbo].[service_location_qualifications]
(
[slq_id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_class] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[service_location_qualifications] ADD CONSTRAINT [pk_slq_id] PRIMARY KEY CLUSTERED ([slq_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[service_location_qualifications] TO [public]
GO
GRANT INSERT ON  [dbo].[service_location_qualifications] TO [public]
GO
GRANT REFERENCES ON  [dbo].[service_location_qualifications] TO [public]
GO
GRANT SELECT ON  [dbo].[service_location_qualifications] TO [public]
GO
GRANT UPDATE ON  [dbo].[service_location_qualifications] TO [public]
GO
