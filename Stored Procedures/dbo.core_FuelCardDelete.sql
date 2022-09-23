SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_FuelCardDelete]
    @fuelcard_crd_vendor varchar(8),
    @fuelcard_crd_cardnumber varchar(20)
AS
	DELETE FROM [cashcard] 
	WHERE   crd_vendor = @fuelcard_crd_vendor
	AND     crd_cardnumber = @fuelcard_crd_cardnumber

GO
GRANT EXECUTE ON  [dbo].[core_FuelCardDelete] TO [public]
GO
