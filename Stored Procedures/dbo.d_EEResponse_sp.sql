SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Proc [dbo].[d_EEResponse_sp] @srpID int 
As
/* 
SR 17782 DPETE created 10/13/03 for retrieving and maintaining Employee response information.  Brings back all for
    a safetye report, must be filtered for an accident or injury or incident within the safety report
 * 10/25/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * 5/20/09 DPETE PTS44645 add user columns
*/

Select eer_ID,
  srp_ID,
  eer_Date,
  eer_MppOrEeID,
  eer_Comment,
  eer_ReviewedBy,
  eer_ReviewedByDate,
  empname = IsNull(e1.emp_name,''),
  empaddress1 = IsNull(e1.emp_address1,''),
  empaddress2 = IsNull(e1.emp_address2,''),
  empcity = IsNull(e1.emp_city,0),
  empCtynmstct = IsNull(e1.emp_Ctynmstct,'UNKNOWN'),
  empstate = IsNull(e1.emp_state,''),
  empzip = IsNull(e1.emp_zip,''),
  empssn = IsNull(e1.emp_ssn,''),
  emplicensenbr = IsNull(e1.emp_Licensenumber,''),
  emplicensestate = IsNull(e1.emp_licensestate,''),
  emplicenseclass = IsNull(e1.emp_licenseclass,'UNK'),emplicenseclass_t = 'LicenseClass',
  emphomephone = IsNull(e1.emp_homephone,''),
  empworkphone = isNull(emp_workphone,''),
  empdateofbirth = e1.emp_dateofbirth,
  emphiredate = e1.emp_hiredate,
  empterminal = IsNull(e1.emp_terminal,'UNK'),empterminal_t = 'Terminal',
  ReviewedByName = IsNull(e2.emp_name,''),
  empsupervisorID = e1.emp_Supervisor,
  empteamleader = e1.emp_teamleader,
  eer_name = isnull(eer_name,''),
  eer_address1 = isnull(eer_address1,''),
  eer_address2 = isnull(eer_address2,''),
  eer_nmstct = isnull(eer_nmstct,''),
  eer_city,
  eer_state = isnull(eer_state,''),
  eer_zip = isnull(eer_zip,''),
  eer_phone1 = isnull(eer_phone1,''),
  eer_phone2 = isnull(eer_phone2,''),
  eer_email = isnull(eer_email,''),
  eer_fax = isnull(eer_fax,''),
  eer_CKBox1 = isnull(eer_CKBox1,'N'),
  eer_CKBox2 = isnull(eer_CKBox2,'N'),
  eer_CKBox3 = isnull(eer_CKBox3,'N'),
  eer_CKBox4 = isnull(eer_CKBox4,'N'),
  eer_CKBox5 = isnull(eer_CKBox5,'N'),
  eer_string1,
  eer_string2,
  eer_string3,
  eer_string4,
  eer_string5,
  eer_number1,
  eer_number2,
  eer_number3,
  eer_number4,
  eer_number5,
  eer_date1,
  eer_date2,
  eer_date3,
  eer_date4,
  eer_date5,
  eer_ResponseType1=IsNull(eer_ResponseType1,'UNK'),eer_ResponseType1_t='ResponseType1',
  eer_ResponseType2=IsNull(eer_ResponseType2,'UNK'),eer_ResponseType2_t='ResponseType2',
  eer_ResponseType3=IsNull(eer_ResponseType3,'UNK'),eer_ResponseType3_t='ResponseType3',
  eer_ResponseType4=IsNull(eer_ResponseType4,'UNK'),eer_ResponseType4_t='ResponseType4' ,
  eer_Respondentis = isnull(eer_respondentis,'E') 
From EEResponse left outer join
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
       emp_EmerName = IsNull(mpp_emerName,''),
       emp_supervisor = '',
       emp_teamleader = IsNull(mpp_Teamleader,'UNK') 
       FROM  city  RIGHT OUTER JOIN  manpowerprofile  ON  city.cty_code  = manpowerprofile.mpp_city  
       Where mpp_id in(Select distinct eer_MppOrEeID From EEResponse where srp_id = @srpid)
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
       emp_WorkPhone = IsNull(ee_Workphone,''),
       emp_DateOfBirth = ee_DateOfBirth,
       emp_HireDate = ee_HireDate,
       emp_terminal = ee_terminal ,
       emp_NbrDependents = IsNull(ee_NbrDependents,0), 
       emp_EmerPhone = IsNull(ee_emerPhone,''),
       emp_EmerName = IsNull(ee_emerName,'') ,
       emp_supervisor = IsNull(ee_SupervisorID,'UNKNOWN'),
       emp_teamleader = '' 
       From employeeprofile 
       Where ee_id  in (Select distinct eer_MppOrEeID From EEResponse where srp_id = @srpid)) e1 on eer_MppOrEeID  = e1.emp_ID left outer join
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
       emp_DateOfBirth = mpp_DateOfBirth,
       emp_HireDate = mpp_HireDate,
       emp_terminal = mpp_terminal ,
       emp_NbrDependents = IsNull(mpp_nbrDependents,0),
       emp_EmerPhone = IsNull(mpp_emerPhone,''),
       emp_EmerName = IsNull(mpp_emerName,''),
       emp_supervisor = '',
       emp_teamleader = IsNull(mpp_Teamleader,'UNK') 
       FROM  city  RIGHT OUTER JOIN  manpowerprofile  ON  city.cty_code  = manpowerprofile.mpp_city  
       Where mpp_id in(Select distinct eer_reviewedBy From EEResponse where srp_id = @srpid)
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
       emp_DateOfBirth = ee_DateOfBirth,
       emp_HireDate = ee_HireDate,
       emp_terminal = ee_terminal ,
       emp_NbrDependents = IsNull(ee_NbrDependents,0), 
       emp_EmerPhone = IsNull(ee_emerPhone,''),
       emp_EmerName = IsNull(ee_emerName,''),
       emp_supervisor = IsNull(ee_SupervisorID,'UNKNOWN'),
       emp_teamleader = '' 
       From employeeprofile 
       Where ee_id  in (Select distinct eer_reviewedBy From EEResponse where srp_id = @srpid)) e2 on eer_ReviewedBy  = e2.emp_id
Where srp_Id =  @srpID
Order by eer_Date

GO
GRANT EXECUTE ON  [dbo].[d_EEResponse_sp] TO [public]
GO
