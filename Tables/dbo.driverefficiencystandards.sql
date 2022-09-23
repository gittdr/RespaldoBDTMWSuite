CREATE TABLE [dbo].[driverefficiencystandards]
(
[id_num] [int] NOT NULL IDENTITY(1, 1),
[des_origin_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[des_dest_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[des_hours] [decimal] (6, 2) NOT NULL,
[des_trip_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[driverefficiencystandards] ADD CONSTRAINT [pk_driverefficiencystandards_id_num] PRIMARY KEY CLUSTERED ([id_num]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_des_origindesttriptype] ON [dbo].[driverefficiencystandards] ([des_origin_id], [des_dest_id], [des_trip_type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[driverefficiencystandards] TO [public]
GO
GRANT INSERT ON  [dbo].[driverefficiencystandards] TO [public]
GO
GRANT REFERENCES ON  [dbo].[driverefficiencystandards] TO [public]
GO
GRANT SELECT ON  [dbo].[driverefficiencystandards] TO [public]
GO
GRANT UPDATE ON  [dbo].[driverefficiencystandards] TO [public]
GO
