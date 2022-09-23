SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_FuelCardExists]
    @fuelcard_crd_vendor varchar(8),
    @fuelcard_crd_cardnumber varchar(20)
AS
	IF Exists (select crd_cardnumber
		FROM [cashcard] WHERE   crd_vendor = @fuelcard_crd_vendor
		AND     crd_cardnumber = @fuelcard_crd_cardnumber)
	Begin
		select cast (1 as bit)
	End
	Else Begin
		select cast (0 as bit)
	End
-- 	SELECT 
-- 	Count(crd_cardnumber)
-- 	FROM [cashcard]
-- 	WHERE   crd_vendor = @fuelcard_crd_vendor
-- 	AND     crd_cardnumber = @fuelcard_crd_cardnumber

GO
GRANT EXECUTE ON  [dbo].[core_FuelCardExists] TO [public]
GO
