SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[GetBillToFuelRelationships] @BILLTO VARCHAR(50)
AS

/*******************************************************************************************************************  
  Object Description:
  Get the BillTo Fuel Relationships for specific billow.

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  11/08/2016   Chip Ciminero    WE-202583   Created
*******************************************************************************************************************/

--CONSIGNEES
SELECT	cmp_address1,cmp_address2,cmp_city=CI.cty_name,cmp_contact,cmp_directions,C.cmp_id,cmp_name,cmp_primaryphone,cmp_secondaryphone 
		, COALESCE(cmp_latseconds/3600.0,cty_latitude) cmp_latitude, COALESCE(cmp_longseconds/3600.0,cty_longitude) cmp_longitude 
		, CI.cty_nmstct, cmp_zip, cmp_othertype1 [cmp_type1], cmp_othertype2 [cmp_type2], cmp_billto, cmp_shipper, cmp_consingee [cmp_consignee], cmp_state
		, FR.delivery, pickup='', supplier='', accountof=''
FROM	company C LEFT OUTER JOIN  city CI ON C.cmp_city = CI.cty_code  INNER JOIN 
		(SELECT DISTINCT delivery FROM fuelrelations WHERE reltype='BILLSHPCNS' AND billto=@BILLTO) FR ON C.cmp_id=FR.delivery  INNER JOIN
		(SELECT DISTINCT delivery FROM fuelrelations WHERE reltype='CMDPIN' AND billto=@BILLTO) FR1 ON FR.Delivery = FR1.Delivery
WHERE	cmp_active = 'Y'  AND C.cmp_consingee='Y'  
ORDER BY c.cmp_id

 --SHIPPERS
SELECT cmp_address1,cmp_address2,cmp_city=CI.cty_name,cmp_contact,cmp_directions,C.cmp_id,cmp_name,cmp_primaryphone,cmp_secondaryphone 
		, COALESCE(cmp_latseconds/3600.0,cty_latitude) cmp_latitude, COALESCE(cmp_longseconds/3600.0,cty_longitude) cmp_longitude 
		, CI.cty_nmstct, cmp_zip, cmp_othertype1 [cmp_type1], cmp_othertype2 [cmp_type2], cmp_billto, cmp_shipper, cmp_consingee [cmp_consignee], cmp_state
		, FR.delivery,FR.pickup, supplier='', accountof=''
FROM	company C LEFT OUTER JOIN  city CI ON C.cmp_city = CI.cty_code  INNER JOIN 
		(SELECT DISTINCT delivery,pickup FROM fuelrelations WHERE reltype='BILLSHPCNS' AND billto=@BILLTO) FR ON C.cmp_id=FR.pickup INNER JOIN
		(SELECT DISTINCT delivery,pickup FROM fuelrelations WHERE reltype='CMDPIN' AND billto=@BILLTO) FR1 ON FR.Delivery = FR1.Delivery AND FR.Pickup = FR1.Pickup
WHERE cmp_active = 'Y'  AND C.cmp_shipper='Y'  ORDER BY c.cmp_id

--SUPPLIERS
 SELECT cmp_address1,cmp_address2,cmp_city=CI.cty_name,cmp_contact,cmp_directions,C.cmp_id,cmp_name,cmp_primaryphone,cmp_secondaryphone 
		, COALESCE(cmp_latseconds/3600.0,cty_latitude) cmp_latitude, COALESCE(cmp_longseconds/3600.0,cty_longitude) cmp_longitude 
		, CI.cty_nmstct, cmp_zip, cmp_othertype1 [cmp_type1], cmp_othertype2 [cmp_type2], cmp_billto, cmp_shipper, cmp_consingee [cmp_consignee], cmp_state
		, delivery='', FR.pickup, FR.supplier, accountof=''
 FROM	company C LEFT OUTER JOIN  city CI ON C.cmp_city = CI.cty_code  INNER JOIN 
		(SELECT DISTINCT pickup,supplier FROM fuelrelations WHERE reltype='BILLRELATE' AND billto=@BILLTO) FR ON C.cmp_id=FR.supplier  INNER JOIN
		(SELECT DISTINCT pickup, supplier FROM fuelrelations WHERE reltype='CMDPIN' AND billto=@BILLTO) FR1 ON FR.Pickup = FR1.Pickup AND FR.Supplier = FR1.Supplier
 WHERE cmp_active = 'Y'  AND C.cmp_supplier='Y'
 ORDER BY c.cmp_id

--ACCOUNTOFS
SELECT	cmp_address1,cmp_address2,cmp_city=CI.cty_name,cmp_contact,cmp_directions,C.cmp_id,cmp_name,cmp_primaryphone,cmp_secondaryphone 
		, COALESCE(cmp_latseconds/3600.0,cty_latitude) cmp_latitude, COALESCE(cmp_longseconds/3600.0,cty_longitude) cmp_longitude 
		, CI.cty_nmstct, cmp_zip, cmp_othertype1 [cmp_type1], cmp_othertype2 [cmp_type2], cmp_billto, cmp_shipper, cmp_consingee [cmp_consignee], cmp_state
		, delivery='', FR.pickup, FR.supplier, FR.accountof
FROM	company C LEFT OUTER JOIN  city CI ON C.cmp_city = CI.cty_code  INNER JOIN 
		(SELECT DISTINCT pickup, supplier, accountof FROM fuelrelations WHERE reltype='BILLRELATE' AND billto=@BILLTO) FR ON C.cmp_id=FR.accountof INNER JOIN
		(SELECT DISTINCT pickup, supplier, accountof FROM fuelrelations WHERE reltype='CMDPIN' AND billto=@BILLTO) FR1 ON FR.Pickup = FR1.Pickup AND FR.Supplier = FR1.Supplier AND FR.AccountOf = FR1.AccountOf
WHERE	cmp_active = 'Y'  AND C.cmp_accountof='Y'  
ORDER BY c.cmp_id

GO
GRANT EXECUTE ON  [dbo].[GetBillToFuelRelationships] TO [public]
GO
