SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[missing_zip_codes]
AS
SELECT
  ZIPCode, City, County, StateCode, ZIPCodeType, Latitude, Longitude, AreaCode, GMTOffset
  FROM
  commercial c
  WHERE ZIPCodeType IN ('S','U') AND CityType IN ('D') AND NOT EXISTS (SELECT * FROM city, cityzip cz WHERE city.cty_code = cz.cty_code AND cz.zip = c.ZIPCode
  AND c.StateCode = city.cty_state)
GO
GRANT DELETE ON  [dbo].[missing_zip_codes] TO [public]
GO
GRANT INSERT ON  [dbo].[missing_zip_codes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[missing_zip_codes] TO [public]
GO
GRANT SELECT ON  [dbo].[missing_zip_codes] TO [public]
GO
GRANT UPDATE ON  [dbo].[missing_zip_codes] TO [public]
GO
