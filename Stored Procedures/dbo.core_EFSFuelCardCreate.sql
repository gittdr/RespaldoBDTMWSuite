SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[core_EFSFuelCardCreate]
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

select @fuelcard_asgn_type = IsNull (@fuelcard_asgn_type, 'USR')
select @fuelcard_asgn_id= IsNull (@fuelcard_asgn_id,'UNKNOWN')
select @fuelcard_crd_driver = IsNull (@fuelcard_crd_driver, 'UNKNOWN')
select @fuelcard_crd_unitnumber = IsNull (@fuelcard_crd_unitnumber, 'UNKNOWN')
select @fuelcard_crd_trailernumber = IsNull (@fuelcard_crd_trailernumber, 'UNKNOWN')
select @fuelcard_crd_carrier = IsNull (@fuelcard_crd_carrier, 'UNKNOWN')
select @fuelcard_crd_thirdpartytype = IsNull (@fuelcard_crd_thirdpartytype, 'UNKNOWN')

INSERT INTO [cashcard] (
    crd_vendor,
    crd_cardnumber,
    crd_accountid,
    crd_customerid,
    asgn_type,
    asgn_id,
    crd_status,
    crd_driver,
    crd_unitnumber,
    crd_trailernumber,
    crd_thirdpartytype,
    crd_carrier,
    crd_createddate,
    crd_importbatch,
    crd_crdnumbershort,
    crd_expcashflagyn,
    crd_tripnumber,
	crd_pinnumber)
VALUES (
    @fuelcard_crd_vendor,
    @fuelcard_crd_cardnumber,
    @fuelcard_crd_accountid,
    @fuelcard_crd_customerid,
    @fuelcard_asgn_type,
    @fuelcard_asgn_id,
    @fuelcard_crd_status,
    @fuelcard_crd_driver,
    @fuelcard_crd_unitnumber,
    @fuelcard_crd_trailernumber,
    @fuelcard_crd_thirdpartytype,
    @fuelcard_crd_carrier,
    GetDate(),
    @fuelcard_crd_importbatch,
    @fuelcard_crd_crdnumbershort,
    '1',
    @fuelcard_crd_tripnumber,
    @fuelcard_crd_pinnumber
)

SELECT crd_createddate as CreatedOn
FROM [cashcard]
WHERE crd_vendor = @fuelcard_crd_vendor
AND crd_cardnumber = @fuelcard_crd_cardnumber

GO
GRANT EXECUTE ON  [dbo].[core_EFSFuelCardCreate] TO [public]
GO
