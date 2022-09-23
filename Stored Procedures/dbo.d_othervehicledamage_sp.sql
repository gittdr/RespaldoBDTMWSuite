SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

 Create Proc [dbo].[d_othervehicledamage_sp] @srpid int  
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
	SR 17782 DPETE created 10/13/03.  Assumes only one shipper and commodity are to be specified  
	PTS 2177 add claim number 
 * 11/30/2007.01 ? PTS40463 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * 3/17/09 DPETE PTS44645 add user columns
 *
 **/
Select ovd_ID,  
  srp_id ,   
  ovd_Sequence,  
  ovd_DriverName = IsNull(ovd_Drivername,''),  
  ovd_DriverAddress1= IsNull(ovd_DriverAddress1,''),  
  ovd_DriverAddress2 = IsNull(ovd_DriverAddress2,''),  
  ovd_DriverCity = IsNull(ovd_DriverCity,0),  
  ovd_DriverCtynmstct = IsNull(ovd_DriverCtynmstct,'UNKNOWN'),  
  ovd_DriverState = IsNull(ovd_DriverState,''),  
  ovd_DriverZip = IsNull(ovd_DriverZip,''),  
  ovd_DriverCountry = IsNull(ovd_DriverCountry,''),  
  ovd_DriverPhone = IsNull(ovd_DriverPhone,''),  
  ovd_VehicleType= IsNull(ovd_Vehicletype,''),  
  ovd_VehicleYear = IsNull(ovd_vehicleyear,0),  
  ovd_VehicleMake = IsNull(ovd_Vehiclemake,''),  
  ovd_VehicleModel = IsNull(ovd_VehicleModel,''),  
  ovd_VehicleVIN= IsNull(ovd_VehicleVIN,''),  
  ovd_VehicleLicense = IsNull(ovd_VehicleLicense,''),  
  ovd_VehicleState = IsNull(ovd_vehicleState,''),  
  ovd_damage = IsNull(ovd_Damage,''),  
  ovd_value = IsNull(ovd_value,0),  
  ovd_Comment = IsNull(ovd_Comment,''),  
  ovd_ActionTaken = IsNull(ovd_ActionTaken,''),  
  ovd_OwnerIs = IsNull(ovd_OwnerIs,'O'),  
  ovd_OwnerCompanyID= IsNull(ovd_OwnerCompanyID,'UNKNOWN'),  
  ovd_OwnerName = IsNull(ovd_OwnerName,''),  
  ovd_OwnerAddress1 = IsNull(ovd_OwnerAddress1,''),  
  ovd_OwnerAddress2 = IsNull(ovd_OwnerAddress2,''),  
  ovd_OwnerCity = IsNull(ovd_ownercity,0),  
  ovd_OwnerCtynmstct = IsNull(ovd_ownerCtynmstct,'UNKNOWN'),  
  ovd_OwnerState = IsNull(ovd_ownerState,''),  
  ovd_ownerzip = IsNull(ovd_OwnerZip,''),  
  ovd_OwnerCountry = IsNull(ovd_OwnerCountry,''),  
  ovd_InsCompany = IsNull(ovd_InsCompany,''),  
  ovd_InsCoAddress= IsNull(ovd_InsCoAddress,''),  
  ovd_InsCoCity = IsNull(ovd_InsCoCity,0),  
  ovd_InsCoCtynmstct= IsNull(ovd_InsCoCtynmstct,'UNKNOWN'),  
  ovd_InsCoState = IsNull(ovd_InsCoState,''),  
  ovd_InsCoZip = IsNull(ovd_InsCOZip,''),  
  ovd_InsCoCountry = IsNull(ovd_InsCoCountry,''),  
  ovd_InsCoPhone = IsNull(ovd_insCoPhone,''),  
  ovd_ReportedToInsurance = IsNull(ovd_ReportedToInsurance,'N'),  
  ovd_InsCoReportDate,  
  cmpname = IsNull(cmp_name,''),  
  cmpaddress1 = IsNull(cmp_address1,''),  
  cmpaddress2 = IsNull(cmp_address2,''),  
  cmpcity = IsNull(cmp_city,0),  
  cmpctynmstct = IsNull(company.cty_nmstct,'UNKNWON'),  
  cmpzip = IsNull(cmp_zip,''),  
  cmpstate = IsNull(cmp_state,''),  
  cmpCountry = IsNull(cmp_country,''),  
  cmpPhone = IsNull(cmp_primaryphone,''),  
  ovd_Ownerphone = IsNull(ovd_Ownerphone,''),
  ovd_Claimnbr = Isnull(ovd_claimnbr,''),
  ovd_string1,
  ovd_string2,
  ovd_string3,
  ovd_string4,
  ovd_string5,
  ovd_number1,
  ovd_number2,
  ovd_number3,
  ovd_number4,
  ovd_number5,
  ovd_OVDamageType1=IsNull(ovd_OVDamageType1,'UNK'),ovd_OVDamageType1_t='OVDamageType1',
  ovd_OVDamageType2=IsNull(ovd_OVDamageType2,'UNK'),ovd_OVDamageType2_t='OVDamageType2',
  ovd_OVDamageType3=IsNull(ovd_OVDamageType3,'UNK'),ovd_OVDamageType3_t='OVDamageType3',
  ovd_OVDamageType4=IsNull(ovd_OVDamageType4,'UNK'),ovd_OVDamageType4_t='OVDamageType4',  
  ovd_date1,
  ovd_date2,
  ovd_date3,
  ovd_date4,
  ovd_date5,
  ovd_CKBox1 = isnull(ovd_CKBox1,'N'),
  ovd_CKBox2 = isnull(ovd_CKBox2,'N'),
  ovd_CKBox3 = isnull(ovd_CKBox3,'N'),
  ovd_CKBox4 = isnull(ovd_CKBox4,'N'),
  ovd_CKBox5 = isnull(ovd_CKBox5,'N')

From   
     othervehicledamage LEFT OUTER JOIN company ON company.cmp_ID = othervehicledamage.ovd_OwnerCompanyID   
Where  
     srp_id = @srpid  
  --And company.cmp_ID =* othervehicledamage.ovd_OwnerCompanyID  
Order by ovd_sequence  
GO
GRANT EXECUTE ON  [dbo].[d_othervehicledamage_sp] TO [public]
GO
