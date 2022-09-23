CREATE TABLE [dbo].[can_carrieralliance]
(
[all_allianceid] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[car_carrierid] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[can_carrieralliance] ADD CONSTRAINT [pk_can_carrieralliance] PRIMARY KEY NONCLUSTERED ([all_allianceid], [car_carrierid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[can_carrieralliance] TO [public]
GO
GRANT INSERT ON  [dbo].[can_carrieralliance] TO [public]
GO
GRANT REFERENCES ON  [dbo].[can_carrieralliance] TO [public]
GO
GRANT SELECT ON  [dbo].[can_carrieralliance] TO [public]
GO
GRANT UPDATE ON  [dbo].[can_carrieralliance] TO [public]
GO
