CREATE TABLE [dbo].[city]
(
[cty_code] [int] NOT NULL,
[cty_name] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cty_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_areacode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_splc] [int] NULL,
[cty_county] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_latitude] [decimal] (14, 6) NULL,
[cty_longitude] [decimal] (14, 6) NULL,
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
[cty_GMTDelta] [float] NULL CONSTRAINT [DF__city__cty_GMTDel__42EE72A4] DEFAULT (null),
[cty_DSTApplies] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__city__cty_DSTApp__43E296DD] DEFAULT ('Y'),
[alk_region] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_city_alk_region] DEFAULT ('NA'),
[cty_TZMins] [smallint] NULL,
[cty_countyfips] [int] NULL,
[cty_statefips] [int] NULL,
[cty_msa] [int] NULL,
[cty_CityShort] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_GeoCodeRequested] [datetime] NULL,
[cty_ALK_FileValidatedYR] [int] NULL,
[cty_splc_char] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_zip_sort] [int] NULL,
[citypoint] [sys].[geography] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create TRIGGER [dbo].[CityDelete]
ON [dbo].[city]
FOR DELETE AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added

DELETE FROM cityzip 
 WHERE cty_code in (SELECT cty_code 
                      FROM deleted)
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create TRIGGER [dbo].[CityInsert]

ON [dbo].[city]

FOR INSERT AS

SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added



DECLARE @jurisvalid VARCHAR(60), @allowinternationalcity Varchar (60) /*PTS 29405 CGK 5/31/2006*/


/*PTS 29405 CGK 5/31/2006*/

SELECT @jurisvalid = gi_string1

  FROM generalinfo 

 WHERE gi_name = 'JurisValid'



SELECT @allowinternationalcity = gi_string1

  FROM generalinfo 

 WHERE gi_name = 'AllowInternationalCity'



/* Updates city "cty_nmstct" field based on name, state & county */

/*END PTS 29405 CGK 5/31/2006*/

If @jurisvalid = 'Y' or @allowinternationalcity = 'Y'

BEGIN

    UPDATE city 

       SET cty_nmstct = inserted.cty_name + CASE WHEN LEN(inserted.cty_state) > 0 THEN ',' + inserted.cty_state 

                                                 WHEN LEN(inserted.cty_country) > 0 THEN ',' + inserted.cty_country 

                                                 ELSE '' END

      FROM city inner join inserted on city.cty_code = inserted.cty_code

     WHERE inserted.cty_code <> 0 

	

	update city

	set city.cty_county = inserted.cty_country

	from  city inner join inserted on CITY.CTY_CODE = INSERTED.CTY_CODE

        WHERE isnull(INSERTED.CTY_COUNTY,'') = ''


END

ELSE

/*END PTS 29405 CGK 5/31/2006*/

UPDATE city 

SET cty_nmstct = inserted.cty_name + ',' + inserted.cty_state + '/' +

isnull(inserted.cty_county, '') 

FROM city , inserted WHERE ( city.cty_code = inserted.cty_code ) AND

( inserted.cty_code <> 0 ) 
and inserted.cty_nmstct is null



INSERT INTO cityzip (zip, cty_code, cty_nmstct)

SELECT city.cty_zip, city.cty_code, city.cty_nmstct 

  FROM city inner join inserted  on city.cty_code = inserted.cty_code 
  left join cityzip on inserted.cty_code = cityzip.cty_code 

 WHERE inserted.cty_zip IS NOT NULL AND 

       inserted.cty_code IS NOT NULL AND
	  
	  cityzip.cty_code is null 


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create TRIGGER [dbo].[CityUpdate]
ON [dbo].[city]
FOR update AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added

DECLARE @rows int,
        @jurisvalid VARCHAR(255), /*PTS 29405 CGK 5/31/2006*/
	@allowinternationalcity Varchar (255) /*PTS 29405 CGK 5/31/2006*/

/*PTS 29405 CGK 5/31/2006*/
SELECT @jurisvalid = gi_string1
  FROM generalinfo 
 WHERE gi_name = 'JurisValid'

/*PTS 29405 CGK 5/31/2006*/
SELECT @allowinternationalcity = gi_string1
  FROM generalinfo 
 WHERE gi_name = 'AllowInternationalCity'

-- Updates city "cty_nmstct" field based on name, state & county when name, state or county are changed
if update(cty_name) or update( cty_state ) or update( cty_county)  or  /*PTS 29405 CGK 5/31/2006*/ update( cty_country) 
/*PTS 29405 CGK 5/31/2006*/
IF @jurisvalid = 'Y' OR @allowinternationalcity = 'Y'
BEGIN
      UPDATE city 
         SET cty_nmstct = inserted.cty_name + CASE WHEN LEN(inserted.cty_state) > 0 THEN ',' + inserted.cty_state 
                                                   WHEN LEN(inserted.cty_country) > 0 THEN ',' + inserted.cty_country 
                                                   ELSE '' END
        FROM city , inserted 
       WHERE city.cty_code = inserted.cty_code AND 
             inserted.cty_code <> 0 
      update city
	set city.cty_county = inserted.cty_country
	from  inserted
        WHERE CITY.CTY_CODE = INSERTED.CTY_CODE
              AND INSERTED.CTY_COUNTY IS NULL

END   
ELSE
/*END PTS 29405 CGK 5/31/2006*/
UPDATE city 
   SET cty_nmstct = inserted.cty_name + ',' + inserted.cty_state + '/' + isnull(inserted.cty_county,'') 
  FROM city , inserted 
 WHERE ( city.cty_code = inserted.cty_code ) AND ( inserted.cty_code <> 0 ) 

IF update(cty_zip)
BEGIN
 --    SELECT @rows = COUNT(*) FROM INSERTED
 --    IF @rows = 1
     BEGIN
          IF NOT EXISTS (SELECT * FROM cityzip, inserted 
                          WHERE cityzip.zip = inserted.cty_zip AND cityzip.cty_code = inserted.cty_code)
          INSERT INTO cityzip (zip, cty_code, cty_nmstct)
          SELECT city.cty_zip, city.cty_code, city.cty_nmstct 
            FROM city, inserted 
           WHERE city.cty_code = inserted.cty_code AND 
                 inserted.cty_zip IS NOT NULL AND 
                 inserted.cty_code IS NOT NULL AND 
                 inserted.cty_nmstct IS NOT NULL
     END
END
     
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
CREATE TRIGGER [dbo].[dt_city] ON [dbo].[city]   
FOR DELETE   
AS  
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added   
 if exists   
  ( select top 1 stops.stp_city from stops inner join deleted  
     on deleted.cty_code = stops.stp_city )   
   begin  
-- Sybase Syntax  
--     raiserror 99999 'Cannot delete city: Assigned to stops'  
-- MSS Syntax  
     raiserror('Cannot delete city: Assigned to stops',16,1)  
     rollback transaction  
   end  
 else  
  if exists  
   ( select top 1 company.cmp_city from company inner join deleted  
      on deleted.cty_code = company.cmp_city )  
    begin  
-- Sybase Syntax  
--     raiserror 99999 'Cannot delete city: Assigned to company'  
-- MSS Syntax  
     raiserror('Cannot delete city: Assigned to company',16,1)  
     rollback transaction  
    end
GO
ALTER TABLE [dbo].[city] ADD CONSTRAINT [pk_city] PRIMARY KEY CLUSTERED ([cty_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_cty_alkcity] ON [dbo].[city] ([alk_state], [alk_city]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_cty_areacode] ON [dbo].[city] ([cty_areacode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cty_fuel] ON [dbo].[city] ([cty_fuelcreate], [cty_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_citylatlong] ON [dbo].[city] ([cty_latitude], [cty_longitude], [cty_fuelcreate]) INCLUDE ([cty_zip], [cty_nmstct]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_nmstct] ON [dbo].[city] ([cty_nmstct], [cty_fuelcreate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_city_region1] ON [dbo].[city] ([cty_region1]) INCLUDE ([cty_zip], [cty_state], [cty_areacode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_city_region2] ON [dbo].[city] ([cty_region2]) INCLUDE ([cty_zip], [cty_state], [cty_areacode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_city_region3] ON [dbo].[city] ([cty_region3]) INCLUDE ([cty_zip], [cty_state], [cty_areacode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_city_region4] ON [dbo].[city] ([cty_region4]) INCLUDE ([cty_zip], [cty_state], [cty_areacode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [k_cty_name_state] ON [dbo].[city] ([cty_state], [cty_name], [cty_county], [cty_fuelcreate]) INCLUDE ([cty_latitude], [cty_longitude], [cty_zip]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_cty_zip] ON [dbo].[city] ([cty_zip]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_city_timestamp] ON [dbo].[city] ([timestamp]) ON [PRIMARY]
GO
CREATE SPATIAL INDEX [ix_city_citypoint] ON [dbo].[city] ([citypoint]) USING geography_grid  WITH (GRIDS = (MEDIUM, MEDIUM, MEDIUM, MEDIUM), CELLS_PER_OBJECT = 16) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[city] TO [public]
GO
GRANT INSERT ON  [dbo].[city] TO [public]
GO
GRANT REFERENCES ON  [dbo].[city] TO [public]
GO
GRANT SELECT ON  [dbo].[city] TO [public]
GO
GRANT UPDATE ON  [dbo].[city] TO [public]
GO
