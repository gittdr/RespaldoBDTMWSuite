SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Object:  Stored Procedure dbo.tariff_engine_init_sp    Script Date: 8/20/97 1:59:41 PM ******/
CREATE PROC [dbo].[tariff_engine_init_sp] (@cmdcode varchar(8),
@orderedby varchar(8),
@trailer varchar(13),
@tractor varchar(8),
@originpoint varchar(8),
@origincity int,
@destpoint varchar(8),
@destcity int,
@cmd_class varchar(8) OUTPUT,
@cmp_othertype1 varchar(6) OUTPUT,
@cmp_othertype2 varchar(6) OUTPUT,
@trl_type1 varchar(6) OUTPUT,
@trl_type2 varchar(6) OUTPUT,
@trl_type3 varchar(6) OUTPUT,
@trl_type4 varchar(6) OUTPUT,
@trl_axles tinyint OUTPUT,
@trc_axles tinyint OUTPUT,
@originzip char(3) OUTPUT,
@originstate varchar(6) OUTPUT,
@origincounty varchar(3) OUTPUT,
@destzip char(3) OUTPUT,
@deststate varchar(6) OUTPUT,
@destcounty varchar(3) OUTPUT)
AS

-- Get the commodity class
SELECT @cmd_class = cmd_class
FROM commodity
WHERE cmd_code = @cmdcode

-- Get the other company types
SELECT @cmp_othertype1 = cmp_othertype1,
       @cmp_othertype2 = cmp_othertype2
FROM company
WHERE cmp_id = @orderedby

-- Get the trailer types and number of axles
SELECT @trl_type1 = trl_type1,
       @trl_type2 = trl_type2,
       @trl_type3 = trl_type3,
       @trl_type4 = trl_type4,
       @trl_axles = trl_axles
FROM trailerprofile
WHERE trl_id = @trailer

-- Get the number of tractor axles
SELECT @trc_axles = trc_axles
FROM tractorprofile
WHERE trc_number = @tractor

-- Get the 1st 3 digits of the zip code for the origin point company
SELECT @originzip = SUBSTRING(cmp_zip, 1, 3)
FROM company
WHERE cmp_id = @originpoint

-- Get the 1st 3 digits of the zip code for the destination point company
SELECT @destzip = SUBSTRING(cmp_zip, 1, 3)
FROM company
WHERE cmp_id = @destpoint

-- Get the state and county for the origin point city
SELECT @originstate = cty_state,
       @origincounty = cty_county
FROM city
WHERE cty_code = @origincity

-- Get the state and county for the destination point city
SELECT @deststate = cty_state,
       @destcounty = cty_county
FROM city
WHERE cty_code = @destcity

-- Fix any nulls
SELECT @cmd_class = IsNull(@cmd_class, ''),
       @cmp_othertype1 = IsNull(@cmp_othertype1, ''),
       @cmp_othertype2 = IsNull(@cmp_othertype2, ''),
       @trl_type1 = IsNull(@trl_type1, ''),
       @trl_type2 = IsNull(@trl_type2, ''),
       @trl_type3 = IsNull(@trl_type3, ''),
       @trl_type4 = IsNull(@trl_type4, ''),
       @trl_axles = IsNull(@trl_axles, 0),
       @trc_axles = IsNull(@trc_axles, 0),
       @originzip = IsNull(@originzip, ''),
       @originstate = IsNull(@originstate, ''),
       @origincounty = IsNull(@origincounty, ''),
       @destzip = IsNull(@destzip, ''),
       @deststate = IsNull(@deststate, ''),
       @destcounty = IsNull(@destcounty, '')
GO
GRANT EXECUTE ON  [dbo].[tariff_engine_init_sp] TO [public]
GO
