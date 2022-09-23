SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[get_city_sp] (@origincitycode int,
@destcitycode int,
@origincityname varchar(18) OUTPUT,
@originstatename varchar(6) OUTPUT,
@destcityname varchar(18) OUTPUT,
@deststatename varchar(6) OUTPUT)
AS

SELECT @origincityname = cty_name, @originstatename = cty_state
	FROM city
	WHERE cty_code = @origincitycode

SELECT @destcityname = cty_name, @deststatename = cty_state
	FROM city
	WHERE cty_code = @destcitycode

SELECT @origincityname = ISNULL(@origincityname, ''),
@originstatename = ISNULL(@originstatename, ''),
@destcityname = ISNULL(@destcityname, ''),
@deststatename = ISNULL(@deststatename, '')


GO
GRANT EXECUTE ON  [dbo].[get_city_sp] TO [public]
GO
