SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[postalcode_to_commercial]
AS
BEGIN
  CREATE TABLE #3digit (
 PostalCode char(3),
 CityName varchar(64),
 CityType char(1),
 ProvinceName varchar(64),
 ProvinceAbbr char(2),
 Latitude decimal(9, 6),
 Longitude decimal(9, 6)
  )
   
   INSERT INTO #3digit SELECT SUBSTRING(PostalCode,1,3),
  CityName,
  CityType,
  ProvinceName,
  ProvinceAbbr,
  MAX(Latitude),
  MAX(Longitude)
 FROM commercial_postalcode
 GROUP BY SUBSTRING(PostalCode,1,3), CityName, CityType, ProvinceName, ProvinceAbbr
  
 INSERT INTO commercial (ZipCode, ZipCodeType, City, CityType, State,
   StateCode, Latitude, Longitude, AreaCode) SELECT PostalCode,
   'S', CityName, CityType, ProvinceName, ProvinceAbbr, Latitude, Longitude, ''
   from #3digit

RETURN 0
END
GO
GRANT EXECUTE ON  [dbo].[postalcode_to_commercial] TO [public]
GO
