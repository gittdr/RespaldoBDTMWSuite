CREATE TABLE [dbo].[ferus_plant_counter]
(
[day_id] [int] NULL,
[plant_1] [int] NULL,
[plant_2] [int] NULL,
[plant_3] [int] NULL,
[plant_4] [int] NULL,
[plant_5] [int] NULL,
[plant_6] [int] NULL,
[plant_7] [int] NULL,
[plant_8] [int] NULL,
[plant_9] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [uk_dayid] ON [dbo].[ferus_plant_counter] ([day_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ferus_plant_counter] TO [public]
GO
GRANT INSERT ON  [dbo].[ferus_plant_counter] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ferus_plant_counter] TO [public]
GO
GRANT SELECT ON  [dbo].[ferus_plant_counter] TO [public]
GO
GRANT UPDATE ON  [dbo].[ferus_plant_counter] TO [public]
GO
