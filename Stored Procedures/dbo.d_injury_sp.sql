SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Proc [dbo].[d_injury_sp] @srpid int
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
	SR 17782 DPETE created 10/13/03.  Assumes only injuries to employees will be recorded at this date  
	   DPETE 2/6 add medical restrictions
	DPETE 2/11/04 21787 remove claim number
 * 11/29/2007.01 ? PTS40462 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * 3/17/09 DPET PTS 44645 add some user fields
 * 5.2009 DPETE add user defined fields PTS 44645
 *
 **/

Select inj_ID,
  srp_id = Injury.srp_ID,
  inj_sequence,
  inj_reportedDate,
--  inj_ClaimNumber,
  inj_Description,
  inj_HowOccurred,
  inj_DateOfFullRelease,
  inj_PersonIs = IsNull(inj_personIs,'O'),
  inj_MppOrEeID,
  inj_Name= IsNull(inj_name,''),        -- if injured personis not an employee
  inj_Address1 = IsNull(inj_address1,''),
  inj_Address2 = IsNull(inj_address2,''),
  inj_City = IsNull(inj_city,0),
  inj_Ctynmstct = IsNull(inj_ctynmstct,''),
  inj_State = IsNull(inj_state,''),
  inj_zip = IsNull(inj_zip,''),
  inj_Country = IsNull(inj_country,''),
  inj_HomePhone = IsNull(inj_HomePhone,''),
  inj_WorkPhone = IsNull(inj_WorkPhone,''),
  inj_LastDateWorked,
  inj_ExpectedReturn,
  inj_ClaimInDoubt,
  inj_InjuryType1, inj_InjuryType1_t = 'InjuryType1',
  inj_InjuryType2, inj_InjuryType2_t = 'InjuryType2',
  inj_IsFatal,
  inj_TreatedAtScene,
  inj_AtSceneCaregiver,
  inj_TreatedAwayFromScene,
  inj_ReportedToInsurance,
  inj_InsCoReportDate,
  empname = IsNull(e1.emp_name,''),
  empaddress1 = IsNull(e1.emp_address1,''),
  empaddress2 = IsNull(e1.emp_address2,''),
  empcity = IsNull(e1.emp_city,0),
  empCtynmstct = IsNull(e1.emp_Ctynmstct,''),
  empstate = IsNull(e1.emp_state,''),
  empzip = IsNull(e1.emp_zip,''),
  empssn = IsNull(e1.emp_ssn,''),
  emplicensenbr = IsNull(e1.emp_Licensenumber,''),
  emplicensestate = IsNull(e1.emp_licensestate,''),
  emplicenseclass = IsNull(e1.emp_licenseclass,'UNK'),emplicenseclass_t = 'LicenseClass',
  emphomephone = IsNull(e1.emp_homephone,''),
  empWorkPhone = IsNull(emp_workphone,''),
  empdateofbirth = e1.emp_dateofbirth,
  emphiredate = e1.emp_hiredate,
  empterminal = IsNull(e1.emp_terminal,'UNK'),empterminal_t = 'Terminal',
  empNbrDependents = IsNull(e1.emp_NbrDependents,0),
  empEmerPhone = IsNull(e1.emp_EmerPhone,''),
  emp_EmerName = IsNull(e1.emp_EmerName,''),
  inj_Maritalstatus = IsNull(inj_maritalstatus,''),
  inj_gender = IsNull(inj_gender,''),
  inj_nbrdependents = IsNull(inj_nbrdependents,0),
  inj_NextSchedAppt,
  inj_DateofBirth,
  inj_ssn = IsNull(inj_ssn,''),
  inj_workstate = IsNull(inj_workstate,''),
  inj_occupation = IsNull(inj_occupation,''),
  inj_MedicalRestrictions = IsNull(inj_medicalRestrictions,''),
  inj_string1,
  inj_string2,
  inj_string3,
  inj_string4,
  inj_string5,
  inj_number1,
  inj_number2,
  inj_number3,
  inj_number4,
  inj_number5,
  inj_InjuryType3 = IsNull(inj_InjuryType3,'UNK'), inj_InjuryType3_t = 'InjuryType3', 
  inj_InjuryType4 = IsNull(inj_InjuryType4,'UNK'), inj_InjuryType4_t = 'InjuryType4', 
  inj_InjuryType5 = IsNull(inj_InjuryType5,'UNK'), inj_InjuryType5_t = 'InjuryType5', 
  inj_InjuryType6 = IsNull(inj_InjuryType6,'UNK'), inj_InjuryType6_t = 'InjuryType6', 
  inj_date1,
  inj_date2,
  inj_date3,
  inj_date4,
  inj_date5,
  inj_CKBox1 = isnull(inj_CKBox1,'N'),
  inj_CKBOx2 = isnull(inj_CKBox2,'N'),
  inj_CKBox3 = isnull(inj_CKBox3,'N'),
  inj_CKBox4 = isnull(inj_CKBox4,'N'),
  inj_CKBox5 = isnull(inj_CKBox5,'N')
From 
  (Select 
       emp_id = mpp_id,
       emp_name = IsNUll(mpp_firstname+' ','')+IsNull(mpp_Middlename+' ','')+IsNull(mpp_lastname,''),
       emp_address1 = IsNull(mpp_Address1,''),
       emp_Address2 = IsNull(mpp_address2,''),
       emp_city = IsNull(mpp_city,0),
       emp_ctynmstct = IsNull(city.cty_nmstct,''),
       emp_state = IsNull(mpp_state,'XX'),
       emp_zip = IsNull(mpp_zip,''),
       emp_ssn = IsNull(mpp_ssn,''),
       emp_LicenseNumber = IsNull(mpp_licenseNumber,''), 
       emp_LicenseState = IsNull(mpp_licenseState,0),
       emp_licenseclass = IsNull(mpp_licenseClass,'UNK'),
       emp_HomePhone = IsNull(mpp_homephone,''),
       emp_WorkPhone = '',
       emp_DateOfBirth = mpp_DateOfBirth,
       emp_HireDate = mpp_HireDate,
       emp_terminal = mpp_terminal ,
       emp_NbrDependents = IsNull(mpp_nbrDependents,0),
       emp_EmerPhone = IsNull(mpp_emerPhone,''),
       emp_EmerName = IsNull(mpp_emerName,'')
       From city RIGHT OUTER JOIN manpowerprofile ON city.cty_code = manpowerprofile.mpp_city
       Where mpp_id in(Select distinct inj_MppOrEeID From Injury where srp_id = @srpid
       and inj_mppOrEEID <> 'UNKNOWN')
       --And city.cty_code =* mpp_city
       Union All
       Select
       emp_id = ee_id, 
       emp_name = IsNUll(ee_firstname+' ','')+IsNull(ee_MiddleInit+' ','')+IsNull(ee_lastname,''),
       emp_address1 = IsNull(ee_Address1,''),
       emp_Address2 = IsNull(ee_address2,''),
       emp_city = IsNull(ee_City,0),
       emp_Ctynmstct = IsNull(ee_Ctynmstct,''),
       emp_state = IsNull(ee_state,'XX'),
       emp_zip = IsNull(ee_zip,''),
       emp_ssn = IsNull(ee_ssn,''),
       emp_LicenseNumber = IsNull(ee_licenseNumber,''), 
       emp_LicenseState = IsNull(ee_licenseState,0),
       emp_LicenseClass = 'UNK',
       emp_HomePhone = IsNull(ee_homephone,''),
       emp_WorkPhone = IsNull(ee_WorkPhone,''),
       emp_DateOfBirth = ee_DateOfBirth,
       emp_HireDate = ee_HireDate,
       emp_terminal = ee_terminal ,
       emp_NbrDependents = IsNull(ee_NbrDependents,0), 
       emp_EmerPhone = IsNull(ee_emerPhone,''),
       emp_EmerName = IsNull(ee_emerName,'') 
       From employeeprofile 
       Where ee_id  in (Select distinct inj_MppOrEeID From Injury where srp_id = @srpid
       and inj_mppOrEEID <> 'UNKNOWN'))
    e1 RIGHT OUTER JOIN injury ON e1.emp_ID = injury.inj_MppOrEeID
		LEFT OUTER JOIN city ON city.cty_Code = injury.inj_City
Where 
  injury.srp_ID = @srpid
--  And e1.emp_ID =* inj_MppOrEeID
--  And city.cty_Code =* inj_City 


  
    

GO
GRANT EXECUTE ON  [dbo].[d_injury_sp] TO [public]
GO
