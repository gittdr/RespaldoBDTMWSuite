SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Proc [dbo].[d_accidentreport01ovd_sp] @srpid int 
As
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
   SR 17782 DPETE created 12/10/03 For subreport of d_accidentreport01_sp with other vehicle damage
 * 11/28/2007.01 ? PTS40462 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

Select srp_id,
  ovd_drivername = IsNull(ovd_drivername,''),
  ovd_Driveraddress1 = IsNull(ovd_DriverAddress1,''),
  ovd_Driveraddress2 = IsNull(ovd_DriverAddress2,''),
  drivercitystatezip = IsNull(c1.cty_name,'')+IsNull(', '+ovd_DriverState,'')+IsNull('    '+ovd_DriverZip,''),
  ovd_DriverPhone = IsNull(ovd_DriverPhone,''),
  ovd_VehicleType= IsNull(ovd_VehicleType,''),
  ovd_VehicleYear = IsNull(ovd_vehicleyear,0),
  ovd_VehicleMake = Isnull(ovd_Vehiclemake,''),
  ovd_VehicleVIN = IsNull(ovd_VehicleVIN,''),
  ovd_VehicleModel = IsNull(ovd_VehicleModel,''),
  ovd_VehicleLicense = IsNull(ovd_VehicleLicense,''),
  ovd_VehicleState = IsNull(ovd_VehicleState,''),
  ovd_OwnerName = IsNull(ovd_Ownername,''),
  ovd_OwnerAddress1 = IsNull(ovd_OwnerAddress1,''),
  ovd_OwnerAddress2 = isNull(ovd_OwnerAddress2,''),
  ownercitystatezip = IsNull(c2.cty_name,'')+IsNull(', '+ovd_ownerState,'')+IsNull('    '+ovd_ownerZip,''),
  ovd_OwnerPhone = IsNull(ovd_OwnerPhone,''),
  ovd_InsCompany = IsNull(ovd_InsCompany,''),
  ovd_InsCoAddress = IsNull(ovd_InsCoAddress,''),
  inscocitystatezip = IsNull(c3.cty_name,'')+IsNull(', '+ovd_InsCoState,'')+IsNull('    '+ovd_InsCozip,''),
  ovd_Damage = IsNull(ovd_Damage,''),
  ovd_value = IsNull(ovd_value,0),
  ovd_ActionTaken = IsNull(ovd_ActionTaken,'')
From 
	(Select cty_code,cty_name From city where cty_code in (Select ovd_DriverCity From othervehicledamage o1 Where o1.srp_ID = @srpid)) c1
		RIGHT OUTER JOIN othervehicledamage 
			ON c1.cty_code = othervehicledamage.ovd_Drivercity 
		LEFT OUTER JOIN (Select cty_code,cty_name From city where cty_code in (Select ovd_OwnerCity From othervehicledamage o2 Where o2.srp_ID = @srpid)) c2
			ON  c2.cty_code = othervehicledamage.ovd_OwnerCity  
		LEFT OUTER JOIN (Select cty_code,cty_name From city where cty_code in (Select ovd_InsCoCity From othervehicledamage o3 Where o3.srp_ID = @srpid)) c3
			ON c3.cty_code  = othervehicledamage.ovd_InsCoCity  --pts40462 outer join conversion
Where srp_ID = @srpid
  
--From othervehicledamage
-- ,(Select cty_code,cty_name From city where cty_code in (Select ovd_DriverCity From othervehicledamage o1 Where o1.srp_ID = @srpid)) c1
--,(Select cty_code,cty_name From city where cty_code in (Select ovd_OwnerCity From othervehicledamage o2 Where o2.srp_ID = @srpid)) c2
--,(Select cty_code,cty_name From city where cty_code in (Select ovd_InsCoCity From othervehicledamage o3 Where o3.srp_ID = @srpid)) c3
--Where srp_ID = @srpid
--  And c1.cty_code =* ovd_Drivercity 
--  And c2.cty_code =* ovd_OwnerCity
--  And c3.cty_code =* ovd_InsCoCity  


GO
GRANT EXECUTE ON  [dbo].[d_accidentreport01ovd_sp] TO [public]
GO
