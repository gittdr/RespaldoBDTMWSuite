SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
Create Proc [dbo].[d_SPILL_sp] @srpid int  
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
	SR 17782 DPETE created 10/13/03.   
	  11/5 save ctynmstct instead of city name (KM says city file should work)  
	DPETE 2/11/4 PTS21787 remove insurance info  
	 DPETE 38551 add rest of law enforcement infor 
 * 11/30/2007.01 ? PTS40463 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * 3/17/09 DPETE PTS 44645 add user fields
 *
 **/  
Select spl_ID,  
  srp_id ,  
  spl_SPILLType1 = IsNull(spl_SPILLType1,'UNK'), spl_SPILLType1_t = 'SpillType1',  
  spl_SPILLType2 = IsNull(spl_SPILLType2,'UNK'), spl_SPILLType2_t = 'SpillType2',  
  spl_Description = IsNull(spl_Description,''),  
  spl_Comment = IsNull(spl_Comment,''),  
  spl_ActionTaken = IsNull(spl_ActionTaken,''),  
  spl_driver1 = IsNull(spl_Driver1,'UNKNOWN'),  
  spl_Driver2 = IsNull(spl_Driver2,'UNKNOWN'),  
  spl_tractor,  
  spl_trailer1,  
  spl_trailer2,  
  spl_Pictures,  
  spl_LawEnfDeptName,  
  spl_LawEnfDeptAddress,  
  spl_LawEnfDeptCity,  
  spl_LawEnfDeptctynmstct = IsNull(spl_LawEnfDeptctynmstct,'UNKNOWN'),  
  spl_LawEnfDeptState,  
  spl_LawEnfDeptZip,  
  spl_LawEnfDeptCountry,  
  spl_LawEnfDeptPhone,  
  spl_LawEnfOfficer,  
  spl_LawEnfOfficerBadge,  
  spl_PoliceReportNumber,  
  spl_AccdntPreventability, spl_AccdntPreventability_t = 'AccdntPreventability',  
  spl_HazMat,  
--  spl_ReportedToInsurance ,  
--  spl_InsCoReportDate,  
  spl_OwnerIs = IsNull(spl_OwnerIs,'C'),  
  spl_OwnerCmpID = IsNUll(spl_OwnerCmpID,'UNKNOWN'),  
  spl_OwnerName = IsNull(spl_OwnerName,''),  
  spl_OwnerAddress1 = IsNull(spl_OwnerAddress1,''),  
  spl_OwnerAddress2 = IsNull(spl_OwnerAddress2,''),  
  spl_Ownercity = IsNull(spl_OwnerCity,0),  
  spl_Ownerctynmstct = IsNull(spl_Ownerctynmstct,'UNKNON'),  
  spl_ownerState = IsNUll(spl_OwnerState,''),  
  spl_OwnerZip = IsNull(spl_OwnerZip,''),  
  spl_OwnerCountry = IsNull(spl_OwnerCountry,''),  
 -- spl_InsCompany = IsNull(spl_InsCompany,''),  
 -- spl_InsCoAddress = IsNull(spl_InsCoAddress,''),  
 -- spl_InsCoCity = IsNull(spl_InsCoCity,0),  
 -- spl_InsCoctynmstct = IsNull(spl_InsCoctynmstct,'UNKNOWN'),  
 -- spl_InsCoState = IsNull(spl_InsCoState,''),  
 -- spl_InsCoZip = IsNull(spl_InsCoZip,''),  
 -- spl_InsCoCountry = IsNull(spl_InsCoCountry,''),  
 -- spl_InsCoPhone = IsNull(spl_InsCoPhone,''),  
  SPILL.mov_number,  -- If occurred on a trip, can pull assets,cmd etc.  
  SPILL.lgh_number,  -- assume first leg if mov entered  
  SPILL.ord_number,  
  SPILL.cmd_code,  
  spl_Shipper = IsNull(spl_shipper,'UNKNOWN'),    
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
      From payto LEFT OUTER JOIN city ON city.cty_code = pto_city Where pto_ID = trc_owner and trc_owner <> 'UNKNOWN' ),''),  
  trl1serial = IsNull(trl1.trl_serial,''),  
  trl1make = IsNull(trl1.trl_make,''),  
  trl1model = IsNull(trl1.trl_model,''),  
  trl1owner = Case IsNull(trl1.trl_owner,'UNKNOWN') When 'UNKNOWN' Then '' Else trl1.trl_owner End,  
  trl1Ownername = (Select IsNull(pto_Fname+' ','')+IsNull(pto_lname,'')+'~r'  
      +IsNull(pto_address1+'~r','')+IsNull(cty_name+', ','')+Isnull(cty_state+'~r','')+  
      IsNull(pto_phone1,'')  
      From payto LEFT OUTER JOIN city ON city.cty_code = pto_city Where pto_ID = trl1.trl_owner and trl1.trl_Owner <> 'UNKNOWN'),   
  trl2serial = IsNull(trl2.trl_serial,''),  
  trl2make = IsNull(trl2.trl_make,''),  
  trl2model = IsNull(trl2.trl_model,''),  
  trl2owner =  Case IsNull(trl2.trl_owner,'UNKNOWN') When 'UNKNOWN' Then '' Else trl2.trl_owner End,  
  trl2Ownername = (Select IsNull(pto_Fname+' ','')+IsNull(pto_lname,'')+'~r'  
      +IsNull(pto_address1+'~r','')+IsNull(cty_name+', ','')+Isnull(cty_state+'~r','')+  
      IsNull(pto_phone1,'')  
      From payto LEFT OUTER JOIN city ON city.cty_code = pto_city Where pto_ID = trl2.trl_owner and trl2.trl_Owner <> 'UNKNOWN'),   
  shippername = IsNull(sc.Cmp_name,''),   
  cmd_name = IsNull(cmd_name,'UNKNOWN'),  
  Delivering = Case When ord_number > '' Then 'O' When mov_number > 0 Then 'M' When lgh_number > 0 Then 'L' Else '      ' End,  
  trcLicense = IsNull(trc_licnum,''),  
  trcLicenseState = IsNull(trc_licstate,''),  
  trl1license = IsNull(trl1.trl_licnum,''),  
  trl1licensestate = IsNull(trl1.trl_Licstate,''),  
  trl2license = IsNull(trl2.trl_licnum,''),  
  trl2licensestate = IsNull(trl2.trl_Licstate,''),  
  trl1year = IsNull(trl1.trl_year,''),  
  trl2year = IsNull(trl2.trl_year,''),  
  spl_damage = IsNull(spl_damage,''),  
  spl_TicketIssued = IsNull(spl_ticketIssued,'N'),  
  spl_TrafficViolation = IsNull(spl_TrafficViolation,'UNK'),spl_TrafficVIolation_t = 'TrafficViolation',  
  spl_carrier = IsnUll(spl_carrier,'UNKNOWN'),  
  carriername =  IsNull(car_name,''),  
  carrieraddress1 = IsNull(car_address1,''),  
  carrieraddress2 = IsNull(car_address2,''),  
  carriercitystate = Case car.cty_code When 0 Then '' Else IsNull(cty_name,'')+IsNull(', '+cty_state,'')+'   '+IsNull(car_zip,'') End,  
  drv1ctynmstct = IsNUll(e1.emp_ctynmstct,'UNKNOWN'),  
  drv2ctynmstct = IsNull(e2.emp_ctynmstct,'UNKNOWN'),  
  spl_ownerphone = IsNull(spl_OwnerPhone,'') , 
  /* added 7/19/07  */
  spl_TicketIssuedTo,
  spl_TicketDesc,
  spl_Points , 
  spl_string1 = isnull(spl_string1,''),
  spl_string2 = isnull(spl_string2,''),
  spl_string3 = isnull(spl_string3,''),
  spl_string4 = isnull(spl_string4,''),
  spl_string5 = isnull(spl_string5,''),
  spl_number1 = isnull(spl_number1,0),
  spl_number2 = isnull(spl_number2,0),
  spl_number3 = isnull(spl_number3,0),
  spl_number4 = isnull(spl_number4,0),
  spl_number5 = isnull(spl_number5,0),
  spl_SpillType3 = IsNull(spl_SPILLType3,'UNK'), spl_SPILLType3_t = 'SpillType3', 
  spl_SpillType4 = IsNull(spl_SPILLType4,'UNK'), spl_SPILLType4_t = 'SpillType4', 
  spl_SpillType5 = IsNull(spl_SPILLType5,'UNK'), spl_SPILLType5_t = 'SpillType5', 
  spl_SpillType6 = IsNull(spl_SPILLType6,'UNK'), spl_SPILLType6_t = 'SpillType6', 
  spl_SpillType6 = IsNull(spl_SPILLType6,'UNK'), spl_SPILLType6_t = 'SpillType6', 
  spl_date1,
  spl_date2,
  spl_date3,
  spl_date4,
  spl_date5,
  spl_ckbox1 = isnull(spl_ckbox1,'N'),
  spl_ckbox2 = isnull(spl_ckbox2,'N'),
  spl_ckbox3 = isnull(spl_ckbox3,'N'),
  spl_ckbox4 = isnull(spl_ckbox4,'N'),
  spl_ckbox5 = isnull(spl_ckbox5,'N')
From     
       (Select   
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
       emp_ctynmstct = IsNull(cty_nmstct,'')  
       From manpowerprofile LEFT OUTER JOIN city ON city.cty_code = manpowerprofile.mpp_city 
       Where mpp_id in(Select distinct spl_driver1 From SPILL where srp_id = @srpid)
       --And city.cty_code =* mpp_city  
       )  
    e1,  
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
       emp_ctynmstct = IsNull(cty_nmstct,'')   
       From manpowerprofile mp2 LEFT OUTER JOIN city ON city.cty_code = mp2.mpp_city  
       Where mp2.mpp_id  in (Select distinct spl_driver2 From SPILL where srp_id = @srpid)  
       --And city.cty_code =* mp2.mpp_city 
      )  
   e2,  
   tractorprofile trc RIGHT OUTER JOIN SPILL ON trc.trc_number = SPILL.spl_tractor
		LEFT OUTER JOIN trailerprofile trl1 ON trl1.trl_id = SPILL.spl_trailer1
		LEFT OUTER JOIN trailerprofile trl2 ON  trl2.trl_id = SPILL.spl_trailer2
		LEFT OUTER JOIN commodity ON Commodity.cmd_code = SPILL.cmd_code
		LEFT OUTER JOIN company sc ON Sc.cmp_id = SPILL.spl_shipper,  
   carrier car,  
   city c1  
Where  
     SPILL.srp_id = @srpid  
     --And trc.trc_number =* spl_tractor  
     --And trl1.trl_id =* spl_trailer1  
     --And trl2.trl_id =* spl_trailer2  
     And IsNull(spl_driver1,'UNKNOWN') = e1.emp_id  -- will not allow outer join here, make sure default is UNKNOWN  
     And IsNull(spl_Driver2,'UNKNOWN') = e2.emp_id   -- will not allow outer join here, make sure default is UNKNOWN for driver2  
     --And Commodity.cmd_code =* SPILL.cmd_code  
     --And Sc.cmp_id =* spl_shipper  
     And car.car_id = IsNull(spl_carrier,'UNKNOWN')  
     And c1.cty_code = car.cty_code  
GO
GRANT EXECUTE ON  [dbo].[d_SPILL_sp] TO [public]
GO
