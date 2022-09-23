CREATE TABLE [dbo].[can_carrier]
(
[car_carrierid] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[car_carriername] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_primarycontact] [char] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_primaryphone] [char] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_primaryfax] [char] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_address1] [char] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_address2] [char] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_city] [char] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_state] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[can_carrier] ADD CONSTRAINT [pk_can_carrier] PRIMARY KEY NONCLUSTERED ([car_carrierid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[can_carrier] TO [public]
GO
GRANT INSERT ON  [dbo].[can_carrier] TO [public]
GO
GRANT REFERENCES ON  [dbo].[can_carrier] TO [public]
GO
GRANT SELECT ON  [dbo].[can_carrier] TO [public]
GO
GRANT UPDATE ON  [dbo].[can_carrier] TO [public]
GO
