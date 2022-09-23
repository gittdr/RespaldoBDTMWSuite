CREATE TABLE [dbo].[cityarchive]
(
[cty_code] [int] NOT NULL,
[cty_name] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cty_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_areacode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_splc] [int] NULL,
[cty_county] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_latitude] [decimal] (12, 4) NULL,
[cty_longitude] [decimal] (12, 4) NULL,
[cty_region1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_region2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_region3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_region4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_nmstct] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[cty_comm_zone] [int] NULL,
[cty_country] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_updateddate] [datetime] NULL,
[cty_createdate] [datetime] NULL,
[rand_city] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rand_state] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rand_county] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alk_city] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alk_state] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alk_county] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_fuelcreate] [smallint] NULL,
[county_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rand_county_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alk_county_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rand_verified] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rand_verified_date] [datetime] NULL,
[alk_verified] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alk_verified_date] [datetime] NULL,
[cty_GMTDelta] [float] NULL,
[cty_DSTApplies] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alk_region] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cty_TZMins] [smallint] NULL,
[cty_countyfips] [int] NULL,
[cty_statefips] [int] NULL,
[cty_msa] [int] NULL,
[cty_CityShort] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_GeoCodeRequested] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cityarchive] ADD CONSTRAINT [pk_cityarchive] PRIMARY KEY CLUSTERED ([cty_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cityarchive] TO [public]
GO
GRANT INSERT ON  [dbo].[cityarchive] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cityarchive] TO [public]
GO
GRANT SELECT ON  [dbo].[cityarchive] TO [public]
GO
GRANT UPDATE ON  [dbo].[cityarchive] TO [public]
GO
