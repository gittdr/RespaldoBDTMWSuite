SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_EFSFuelCardUpdate]
    @fuelcard_crd_vendor varchar(8),
    @fuelcard_crd_cardnumber varchar(20),
    @fuelcard_crd_accountid varchar(10),
    @fuelcard_crd_customerid varchar(10),
    @fuelcard_crd_status varchar(6),
    @fuelcard_asgn_type varchar(6),
    @fuelcard_asgn_id varchar(13),
    @fuelcard_crd_driver varchar(8),
    @fuelcard_crd_unitnumber varchar(8),
    @fuelcard_crd_trailernumber varchar(10),
    @fuelcard_crd_thirdpartytype varchar(8),
    @fuelcard_crd_carrier varchar(8),
    @fuelcard_crd_importbatch varchar (20),
    @fuelcard_crd_crdnumbershort varchar (20),
    @fuelcard_crd_tripnumber varchar (10),
    @fuelcard_crd_pinnumber varchar(12)

AS

	select @fuelcard_crd_driver = IsNull (@fuelcard_crd_driver, 'UNKNOWN')
	select @fuelcard_crd_unitnumber = IsNull (@fuelcard_crd_unitnumber, 'UNKNOWN')
	select @fuelcard_crd_trailernumber = IsNull (@fuelcard_crd_trailernumber, 'UNKNOWN')
	select @fuelcard_crd_carrier = IsNull (@fuelcard_crd_carrier, 'UNKNOWN')
	select @fuelcard_crd_thirdpartytype = IsNull (@fuelcard_crd_thirdpartytype, 'UNKNOWN')

	UPDATE [cashcard]
	SET
	    crd_vendor = @fuelcard_crd_vendor,
	    crd_cardnumber = @fuelcard_crd_cardnumber,
	    crd_accountid = @fuelcard_crd_accountid,
	    crd_customerid = @fuelcard_crd_customerid,
	    asgn_type = @fuelcard_asgn_type,
	    asgn_id = @fuelcard_asgn_id,
	    crd_status = @fuelcard_crd_status,
	    crd_driver = @fuelcard_crd_driver,
	    crd_unitnumber = @fuelcard_crd_unitnumber,
	    crd_trailernumber =@fuelcard_crd_trailernumber,
	    crd_thirdpartytype = @fuelcard_crd_thirdpartytype,
	    crd_carrier = @fuelcard_crd_carrier,
	    crd_importbatch = @fuelcard_crd_importbatch,
	    crd_crdnumbershort = @fuelcard_crd_crdnumbershort,
	    crd_tripnumber = @fuelcard_crd_tripnumber,
	    crd_pinnumber = @fuelcard_crd_pinnumber
	WHERE 	crd_vendor = @fuelcard_crd_vendor
	AND     crd_accountid = @fuelcard_crd_accountid 
	AND     crd_customerid = @fuelcard_crd_customerid
	AND crd_cardnumber = @fuelcard_crd_cardnumber

GO
GRANT EXECUTE ON  [dbo].[core_EFSFuelCardUpdate] TO [public]
GO
