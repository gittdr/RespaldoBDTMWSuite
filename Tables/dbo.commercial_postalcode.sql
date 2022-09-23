CREATE TABLE [dbo].[commercial_postalcode]
(
[PostalCode] [char] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CityName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CityType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProvinceName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProvinceAbbr] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Latitude] [decimal] (9, 6) NULL,
[Longitude] [decimal] (9, 6) NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[commercial_postalcode] TO [public]
GO
GRANT INSERT ON  [dbo].[commercial_postalcode] TO [public]
GO
GRANT REFERENCES ON  [dbo].[commercial_postalcode] TO [public]
GO
GRANT SELECT ON  [dbo].[commercial_postalcode] TO [public]
GO
GRANT UPDATE ON  [dbo].[commercial_postalcode] TO [public]
GO
