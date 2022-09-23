SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Proc [dbo].[d_accident_sp] @srpid int
As

/**
 * 
 * NAME:
 * dbo.d_accident_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure deletes note data for the specified
 * registration.
 *
 * RETURNS:
 * N/A
 *
 * RESULT SETS: 
 * See selection list
 *
 * PARAMETERS:
 * 001 - @srp_id, int, input, null;
 *       This parameter indicates the id which we will be using to filter results.
 * 
 *
 * REFERENCES: 
 *
 * NONE
 * 
 * REVISION HISTORY:
	SR 17782 DPETE created 10/13/03.  Assumes only one shipper and commodity are to be specified
	and only one accident record per safety report max
 * 02/16/2006.01 ? PTS31229 - Phil Bidinger ? Added in the acd_teamleader column to this query so that teamleaders
 *  can be associated with a driver in an accident.
 * 3/17/09 DPETE PTS44645 add some user fields
 * PTS44645 DPPETE 5/2009 add user defined fields
 * 04/06/11 vjh PTS 53214 add drv and od hours
*/


Select acd_ID,
  srp_id = accident.srp_ID,
  acd_AccidentType1 = IsNull(acd_AccidentType1,'UNK'), acd_AccidentType1_t = 'AccidentType1',
  acd_AccidentType2 = IsNull(acd_AccidentType2,'UNK'), acd_AccidentType2_t = 'AccidentType2',
  acd_VehicleRole = IsNull(acd_VehicleRole,'UNK'), acd_VehicleROle_t = 'VehicleRole',
  acd_Description = IsNull(acd_Description,''),
  acd_DOTRecordable = IsNull(acd_DOTRecordable,'N') ,
  acd_RoadSituation, acd_RoadSituation_t = 'RoadSituation',
  acd_Illumination , acd_Illumination_t = 'Illumination',
  acd_WeatherType, acd_WeatherType_t = 'WeatherType',
  acd_RoadSurface, acd_RoadSurface_t = 'RoadSurface',
  acd_NbrOfInjuries = IsNull(acd_NbrOfInjuries,0),
  acd_NbrOfFatalities = IsNull(acd_NbrofFatalities,0) ,
  acd_AlcoholTestDone = IsNull(acd_Alcoholtestdone,'N'),
  acd_HoursToAlcoholTest = IsNull(acd_HoursToAlcoholTest,0),
  acd_AlcoholTestDate,
  acd_AlcoholTestResult = IsNull(acd_AlcoholTestResult,'N'),
  acd_DrugTestDone = IsNull(acd_DrugTestDone,'N'),
  acd_HoursToDrugTest = IsNull(acd_HoursToDrugTest,0),
  acd_DrugTestDate,
  acd_DrugTestResult = IsNull(acd_DrugTestResult,'N'),
  acd_CorrectiveActionReq = IsNull(acd_CorrectiveActionReq,'N'),
  acd_driver1 = IsNull(acd_driver1,'UNKNOWN'),
  acd_Driver2 = IsNull(acd_Driver2,'UNKNWON'),
  acd_tractor = IsNull(acd_tractor,'UNKNOWN'),
  acd_trcdamage,
  acd_trailer1 = IsNull(acd_trailer1,'UNKNOWN'),
  acd_trailer2 = IsNull(acd_trailer2,'UNKNOWN'),
  acd_Pictures = IsNull(acd_Pictures,'N'),
  acd_CVDamage,
  acd_Trl1Damage,
  acd_Trl2Damage,
  acd_VehicleTowed = IsNull(acd_VehicleTowed,'N'),
  acd_TowDestination = IsNull(acd_TowDestination,''),
  acd_TowDestAddress = IsNull(acd_TowDestAddress,''),
  acd_TowDestCity = IsNull(acd_TowDestCity,0),
  acd_TowDestCtynmstct = IsNull(acd_TowDestCtynmstct,'UNKNOWN'),
  acd_TowDestState = IsNull(acd_TowDestState,''),
  acd_TowDestZip = IsNull(acd_TowDestZip,''),
  acd_TowDestCountry = IsNull(acd_TowDestCountry,''),
  acd_TowDestPhone = IsNull(acd_TowDestPhone,''),
  acd_LawEnfDeptName = IsNull(acd_LawEnfDeptName,''),
  acd_LawEnfDeptAddress = IsNull(acd_LawEnfDeptAddress,''),
  acd_LawEnfDeptCity = IsNull(acd_LawEnfDeptCity,0),
  acd_LawEnfDeptCtynmstct = IsNull(acd_LawEnfDeptCtynmstct,'UNKNOWN'),
  acd_LawEnfDeptState = IsNull(acd_LawEnfDeptState,''),
  acd_LawEnfDeptCountry = IsNull(acd_LawEnfDeptCountry,''),
  acd_LawEnfDeptZip = IsNull(acd_LawEnfDeptZip,''),
  acd_LawEnfDeptPhone = IsNull(acd_LawEnfDeptPhone,''),
 -- acd_LawEnfDepartment = IsNull(acd_LawEnfDepartment,''),
  acd_LawEnfOfficer = IsNull(acd_LawEnfOfficer,''),
  acd_LawEnfOfficerBadge = IsNull(acd_LawEnfOfficerBadge,''),
  acd_PoliceReportNumber = IsNull(acd_PoliceReportNumber,''),
  acd_TicketIssued = IsNull(acd_TicketIssued,'N'),
  acd_TicketIssuedTo,
  acd_TrafficViolation = IsNull(acd_TrafficViolation,'UNK'),acd_TrafficViolation_t = 'TrafficViolation',
  acd_TicketDesc = IsNull(acd_TicketDesc,''),
  acd_Points,
  acd_AccdntPreventability, acd_AccdntPreventability_t = 'AccdntPreventability',
  acd_HazMat = IsNull(acd_HazMat,0),
  acd_EstSpeed,
  acd_RoadType, acd_RoadType_t = 'RoadType',
  acd_ReportedToInsuranceCo = IsNull(acd_ReportedToInsuranceCo,'N'),
  acd_InsReportDate,
  acd_OVDamaged,
  acd_OPDamaged,
  Accident.mov_number,  -- If occurred on a trip, can pull assets,cmd etc.
  Accident.lgh_number,  -- assume first leg if mov entered
  Accident.ord_number,
  Accident.cmd_code,
  acd_Shipper = IsNull(acd_shipper,'UNKNOWN'),  
  drv1name = IsNull(e1.emp_name,''),
  drv1address1 = IsNull(e1.emp_address1,''),
  drv1address2 = IsNull(e1.emp_address2,''),
  drv1city = IsNull(e1.emp_city,0),
  drv1CityName = IsNull(e1.emp_CityName,''),
  drv1state = IsNull(e1.emp_state,''),
  drv1zip = IsNull(e1.emp_zip,''),
  drv1ssn = IsNull(e1.emp_ssn,''),
  drv1licensenbr = IsNull(e1.emp_Licensenumber,''),
  drv1licensestate = IsNull(e1.emp_licensestate,''),
  drv1licenseclass = IsNull(e1.emp_licenseclass,'UNK'),
  drv1homephone = IsNull(e1.emp_homephone,''),
  drv1dateofbirth = e1.emp_dateofbirth,
  drv1hiredate = e1.emp_hiredate,
  drv1terminal = IsNull(e1.emp_terminal,'UNK'),
  drv1NbrDependents = IsNull(e1.emp_NbrDependents,0),
  drv1EmerName = IsNUll(e1.emp_emerName,''),
  drv1EmerPhone = IsNull(e1.emp_emerPhone,''),
  drv2name = IsNull(e2.emp_name,''),
  drv2address1 = IsNull(e2.emp_address1,''),
  drv2address2 = IsNull(e2.emp_address2,''),
  drv2city = IsNull(e2.emp_city,0),
  drv2CityName = IsNull(e2.emp_CityName,''),
  drv2state = IsNull(e2.emp_state,''),
  drv2zip = IsNull(e2.emp_zip,''),
  drv2ssn = IsNull(e2.emp_ssn,''),
  drv2licensenbr = IsNull(e2.emp_Licensenumber,''),
  drv2licensestate = IsNull(e2.emp_licensestate,''),
  drv2licenseclass = IsNull(e2.emp_licenseclass,'UNK'),
  drv2homephone = IsNUll(e2.emp_homephone,''),
  drv2dateofbirth = e2.emp_dateofbirth,
  drv2hiredate = e2.emp_hiredate,
  drv2terminal = IsNull(e2.emp_terminal,'UNK'),
  drv2NbrDependents = IsNull(e2.emp_NbrDependents,0),
  drv2EmerName = IsNUll(e2.emp_emerName,''),
  drv2EmerPhone = IsNull(e2.emp_emerPhone,''),
  trcserial = IsNull(trc_serial,''),
  trcyear = IsNull(trc_year,''),
  trcmake = IsNull(trc_make,''),
  trcmodel = IsNull(trc_model,''),
  trcOwner= Case IsNull(trc_owner,'UNKNOWN') When 'UNKNOWN' Then '' Else trc_Owner End,
  trcownername = IsNull((Select IsNull(pto_Fname+' ','')+IsNull(pto_lname,'')+'~r'
      +IsNull(pto_address1+'~r','')+IsNull(cty_name+', ','')+Isnull(cty_state+'~r','')+
      IsNull(pto_phone1,'')
      From payto RIGHT OUTER JOIN city ON pto_city = cty_code  Where pto_ID = trc_owner and trc_owner <> 'UNKNOWN'),''),
  trl1serial = IsNull(trl1.trl_serial,''),
  trl1make = IsNull(trl1.trl_make,''),
  trl1model = IsNull(trl1.trl_model,''),
  trl1owner = Case IsNull(trl1.trl_owner,'UNKNOWN') When 'UNKNOWN' Then '' Else trl1.trl_owner End,
  trl1Ownername = (Select IsNull(pto_Fname+' ','')+IsNull(pto_lname,'')+'~r'
      		   +IsNull(pto_address1+'~r','')+IsNull(cty_name+', ','')+Isnull(cty_state+'~r','')+
      		   IsNull(pto_phone1,'')
      		   From payto RIGHT OUTER JOIN city ON pto_city = city.cty_code Where pto_ID = trl1.trl_owner and trl1.trl_Owner <> 'UNKNOWN'), 
  trl2serial = IsNull(trl2.trl_serial,''),
  trl2make = IsNull(trl2.trl_make,''),
  trl2model = IsNull(trl2.trl_model,''),
  trl2owner =  Case IsNull(trl2.trl_owner,'UNKNOWN') When 'UNKNOWN' Then '' Else trl2.trl_owner End,
  trl2Ownername = (Select IsNull(pto_Fname+' ','')+IsNull(pto_lname,'')+'~r'
      		  +IsNull(pto_address1+'~r','')+IsNull(cty_name+', ','')+Isnull(cty_state+'~r','')+
      		  IsNull(pto_phone1,'')
      		  From payto RIGHT OUTER JOIN city ON pto_city = city.cty_code 
      		  Where pto_ID = trl2.trl_owner and trl2.trl_Owner <> 'UNKNOWN'), 
  shippername = IsNull(sc.Cmp_name,''), 
  cmd_name = IsNull(cmd_name,'UNKNOWN'),
  Delivering = Case When ord_number > '' Then 'O' When mov_number > 0 Then 'M' When lgh_number > 0 Then 'l' Else  '      ' End,
  acd_DriverAtWheel,
  acd_comment = IsNull(acd_comment,''),
  trcLicense = IsNull(trc_licnum,''),
  trcLicenseState = IsNull(trc_licstate,''),
  trl1license = IsNull(trl1.trl_licnum,''),
  trl1licensestate = IsNull(trl1.trl_Licstate,''),
  trl2license = IsNull(trl2.trl_licnum,''),
  trl2licensestate = IsNull(trl2.trl_Licstate,''),
  trl1year = IsNull(trl1.trl_year,''),
  trl2year = IsNull(trl2.trl_year,''),
  drv1ctynmstct = IsNull(e1.emp_ctynmstct ,''),
  drv2ctynmstct = IsNull(e2.emp_ctynmstct ,''),
  acd_Carrier = IsNull(acd_carrier,'UNKNOWN'),
  carriername =  IsNull(car.car_name,''),
  carrieraddress1 = IsNull(car.car_address1,''),
  carrieraddress2 = IsNull(car.car_address2,''),
  carriercitystate = Case car.cty_code When 0 Then '' Else IsNull(cty_name,'')+IsNull(', ' + cty_state,'')+'   '+IsNull(car.car_zip,'') End,
  acd_cmpissuedpoints,
  acd_teamleader = IsNull(acd_teamleader, 'Unknown'),
  acd_string1 = isnull(acd_string1,''),
  acd_string2 = isnull(acd_string2,''),
  acd_string3 = isnull(acd_string3,''),
  acd_string4 = isnull(acd_string4,''),
  acd_string5 = isnull(acd_string5,''),
  acd_number1 = isnull(acd_number1,0),
  acd_number2 = isnull(acd_number2,0),
  acd_number3 = isnull(acd_number3,0),
  acd_number4 = isnull(acd_number4,0),
  acd_number5 = isnull(acd_number5,0),
  acd_AccidentType3 = IsNull(acd_AccidentType3,'UNK'), acd_AccidentType3_t = 'AccidentType3',
  acd_AccidentType4 = IsNull(acd_AccidentType4,'UNK'), acd_AccidentType4_t = 'AccidentType4',
  acd_AccidentType5 = IsNull(acd_AccidentType5,'UNK'), acd_AccidentType5_t = 'AccidentType5',
  acd_AccidentType6 = IsNull(acd_AccidentType6,'UNK'), acd_AccidentType6_t = 'AccidentType6',
  acd_AccidentType7 = IsNull(acd_AccidentType7,'UNK'), acd_AccidentType7_t = 'AccidentType7',
  acd_date1,
  acd_date2,
  acd_date3,
  acd_date4,
  acd_date5,
  acd_bigstring1 = isnull(acd_bigstring1,''),
  acd_CKBox1  = isnull(acd_CKBox1,'N'),
  acd_CKBox2 = isnull(acd_CKBox2,'N'),
  acd_CKBox3 = isnull(acd_CKBox3,'N'),
  acd_CKBox4 = isnull(acd_CKBox4,'N'),
  acd_CKBox5 = isnull(acd_CKBox5,'N'),
  acd_logdrvhours,
  acd_logodhours
From 
     accident LEFT OUTER JOIN tractorprofile trc
	ON accident.acd_tractor = trc.trc_number
	LEFT OUTER JOIN trailerprofile trl1
	ON accident.acd_trailer1 = trl1.trl_id
	LEFT OUTER JOIN trailerprofile trl2
	ON accident.acd_trailer2 = trl2.trl_id
        -- change e1 and e2 Joins
	LEFT OUTER JOIN
       (SELECT 
       emp_id = mpp_id,
       emp_name = IsNUll(mpp_firstname+' ','')+IsNull(mpp_Middlename+' ','')+IsNull(mpp_lastname,''),
       emp_address1 = IsNull(mpp_Address1,''),
       emp_Address2 = IsNull(mpp_address2,''),
       emp_city = IsNull(mpp_city,0),
       emp_cityName = IsNull(city.cty_name,''),
       emp_state = IsNull(mpp_state,'XX'),
       emp_zip = IsNull(mpp_zip,''),
       emp_ssn = IsNull(mpp_ssn,''),
       emp_LicenseNumber = IsNull(mpp_licenseNumber,''), 
       emp_LicenseState = IsNull(mpp_licenseState,0),
       emp_licenseclass = IsNull(mpp_licenseClass,'UNK'),
       emp_HomePhone = IsNull(mpp_homephone,''),
       emp_DateOfBirth = mpp_DateOfBirth,
       emp_HireDate = mpp_HireDate,
       emp_terminal = mpp_terminal ,
       emp_NbrDependents = IsNull(mpp_nbrDependents,0),
       emp_EmerPhone = IsNull(mpp_emerPhone,''),
       emp_EmerName = IsNull(mpp_emerName,''),
       emp_ctynmstct = IsNull(city.cty_nmstct,'')
       From manpowerprofile RIGHT OUTER JOIN city
       ON mpp_city = city.cty_code
       Where mpp_id in(SELECT DISTINCT acd_driver1 FROM accident WHERE srp_id = @srpid)
       UNION All
       SELECT
       emp_id = ee_id, 
       emp_name = IsNUll(ee_firstname+' ','')+IsNull(ee_MiddleInit+' ','')+IsNull(ee_lastname,''),
       emp_address1 = IsNull(ee_Address1,''),
       emp_Address2 = IsNull(ee_address2,''),
       emp_city = IsNull(ee_City,0),
       emp_CityName = IsNull(cty_name,''),
       emp_state = IsNull(ee_state,'XX'),
       emp_zip = IsNull(ee_zip,''),
       emp_ssn = IsNull(ee_ssn,''),
       emp_LicenseNumber = IsNull(ee_licenseNumber,''), 
       emp_LicenseState = IsNull(ee_licenseState,0),
       emp_LicenseClass = 'UNK',
       emp_HomePhone = IsNull(ee_homephone,''),
       emp_DateOfBirth = ee_DateOfBirth,
       emp_HireDate = ee_HireDate,
       emp_terminal = ee_terminal,
       emp_NbrDependents = IsNull(ee_NbrDependents,0), 
       emp_EmerPhone = IsNull(ee_emerPhone,''),
       emp_EmerName = IsNull(ee_emerName,''),
       emp_ctynmstct = IsNull(ee_ctynmstct,'') 
       From employeeprofile RIGHT OUTER JOIN city
       ON ee_city = city.cty_code
       Where ee_id in (Select distinct acd_driver1 From accident where srp_id = @srpid)
                       AND ee_id <> 'UNKNOWN')
       e1 ON acd_driver1 = e1.emp_id
       LEFT OUTER JOIN
       (Select 
       emp_id = mp2.mpp_id,
       emp_name = IsNUll(mp2.mpp_firstname+' ','')+IsNull(mp2.mpp_Middlename+' ','')+IsNull(mp2.mpp_lastname,''),
       emp_address1 = IsNull(mp2.mpp_Address1,''),
       emp_Address2 = IsNull(mp2.mpp_address2,''),
       emp_city = IsNull(mp2.mpp_city,0),
       emp_CityName = IsNull(city.cty_name,''),
       emp_state = IsNull(mp2.mpp_state,'XX'),
       emp_zip = IsNull(mp2.mpp_zip,''),
       emp_ssn = IsNull(mpp_ssn,''),
       emp_LicenseNumber = IsNull(mp2.mpp_licenseNumber,''), 
       emp_LicenseState = IsNull(mp2.mpp_licenseState,0),
       emp_licenseclass = IsNull(mp2.mpp_licenseClass,'UNK'),
       emp_HomePhone = IsNull(mp2.mpp_homephone,''),
       emp_DateOfBirth = mp2.mpp_DateOfBirth,
       emp_HireDate = mp2.mpp_HireDate,
       emp_terminal = mp2.mpp_terminal,
       emp_NbrDependents = IsNull( mpp_nbrDependents,0),
       emp_EmerPhone = IsNull(mpp_emerPhone,''),
       emp_EmerName = IsNull(mpp_emerName,''),
       emp_ctynmstct = IsNull(city.cty_nmstct,'')
       From manpowerprofile mp2 RIGHT OUTER JOIN city
       ON mp2.mpp_city = city.cty_code
       Where mp2.mpp_id  in (Select distinct acd_driver2 From accident where srp_id = @srpid))
       e2 ON acd_Driver2 = e2.emp_id
       -- Need to change above
       LEFT OUTER JOIN commodity
       ON accident.cmd_code = commodity.cmd_code
       LEFT OUTER JOIN company sc
       ON acd_shipper = sc.cmp_id 
       LEFT OUTER JOIN carrier car
       ON acd_carrier = car.car_id
       JOIN city c1
       ON c1.cty_code = car.cty_code

WHERE accident.srp_id = @srpid

GO
GRANT EXECUTE ON  [dbo].[d_accident_sp] TO [public]
GO
