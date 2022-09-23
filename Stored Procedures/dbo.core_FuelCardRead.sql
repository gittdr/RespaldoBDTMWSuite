SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_FuelCardRead]
    @fuelcard_crd_vendor varchar(8),
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
   	    crd_primary_tractor AS fuelcard_crd_primary_tractor
	FROM [cashcard]
	WHERE   crd_vendor = @fuelcard_crd_vendor
	AND     crd_cardnumber = @fuelcard_crd_cardnumber

	SELECT  tfo_id as tck_fuel_optimization_tfo_id,
		tfo_expiration_date as tck_fuel_optimization_tfo_expiration_date,
		tfo_maximum_truck_volume as tck_fuel_optimization_tfo_maximum_truck_volume,
		tfo_status as tck_fuel_optimization_tfo_status,
		tfo_sitenumber as tck_fuel_optimization_tfo_sitenumber,
		tck_account_number as tck_fuel_optimization_tck_account_number,
		crd_cardnumber as tck_fuel_optimization_crd_cardnumber,
		crd_cardnumbershort as tck_fuel_optimization_crd_cardnumbershort
	FROM tck_fuel_optimization
	WHERE crd_cardnumber = @fuelcard_crd_cardnumber
	


GO
GRANT EXECUTE ON  [dbo].[core_FuelCardRead] TO [public]
GO
