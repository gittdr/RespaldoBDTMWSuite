SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_EFSFuelCardDelete]
    @fuelcard_crd_vendor varchar(8),
    @fuelcard_crd_accountid varchar(10),
    @fuelcard_crd_customerid varchar(10),
    @fuelcard_crd_cardnumber varchar(20)
AS
	UPDATE cashcard 
	SET crd_status = 'D'
	WHERE   crd_vendor = @fuelcard_crd_vendor
	AND     crd_accountid = @fuelcard_crd_accountid 
	AND     crd_customerid = @fuelcard_crd_customerid
	AND     crd_cardnumber = @fuelcard_crd_cardnumber

GO
GRANT EXECUTE ON  [dbo].[core_EFSFuelCardDelete] TO [public]
GO
