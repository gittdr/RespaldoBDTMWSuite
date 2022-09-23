SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[tcg_location_miles_sp] (@mileagetype int)AS
SELECT LEFT(mt_origin + SPACE(9), 9) from_location_code,
       LEFT(mt_destination + SPACE(9), 9) to_location_code,
       STR(mt_miles, 4, 0) miles
FROM   mileagetable
WHERE  mt_type = @mileagetype

GO
