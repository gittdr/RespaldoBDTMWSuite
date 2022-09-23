SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[tcg_location_names_sp] (@mileagetype int)AS
SELECT LEFT(cty_name + SPACE(20), 20) location_name,
       LEFT(cty_state + SPACE(2), 2) state,
       LEFT(STR(cty_code, 9, 0) + SPACE(9), 9) location_code
FROM   city

GO
