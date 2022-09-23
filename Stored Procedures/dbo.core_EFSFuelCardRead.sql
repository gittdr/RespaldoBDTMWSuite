SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_EFSFuelCardRead]
    @fuelcard_crd_vendor varchar(8),
    @fuelcard_crd_accountid varchar(10),
    @fuelcard_crd_customerid varchar(10),
    @fuelcard_crd_cardnumber varchar(20)
AS
	SELECT 
	    crd_vendor AS fuelcard_crd_vendor,
	    crd_cardnumber AS fuelcard_crd_cardnumber,
	    crd_accountid AS fuelcard_crd_accountid,
	    crd_customerid AS fuelcard_crd_customerid,
	    asgn_type AS fuelcard_asgn_type,
	    asgn_id AS fuelcard_asgn_id,
	    crd_status AS fuelcard_crd_status,
	    crd_driver AS fuelcard_crd_driver,
	    crd_unitnumber AS fuelcard_crd_unitnumber,
	    crd_trailernumber AS fuelcard_crd_trailernumber,
	    crd_thirdpartytype AS fuelcard_crd_thirdpartytype,
	    crd_carrier AS fuelcard_crd_carrier,
	    crd_createddate AS fuelcard_crd_createddate,
	    crd_importbatch AS fuelcard_crd_importbatch,
	    crd_crdnumbershort As fuelcard_crd_crdnumbershort,
	    crd_tripnumber AS fuelcard_crd_tripnumber,
	    crd_pinnumber AS fuelcard_crd_pinnumber
	FROM [cashcard]
	WHERE   crd_vendor = @fuelcard_crd_vendor
	AND     crd_accountid = @fuelcard_crd_accountid 
	AND     crd_customerid = @fuelcard_crd_customerid
	AND     crd_cardnumber = @fuelcard_crd_cardnumber

GO
GRANT EXECUTE ON  [dbo].[core_EFSFuelCardRead] TO [public]
GO
