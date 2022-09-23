SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Proc [dbo].[d_observation_sp] @srpid int
As
/* 
SR 17782 DPETE created 10/13/03. 
    If observer is employee, info is held in manpower or employee.  If observer is outside company, 
    info (address, etc. ) is kept in record. 
 * 11/30/2007.01 ? PTS40463 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * 3/17/09 DPETE PTS44645 add user columns
*/

Select obs_ID,
  srp_id ,
  obs_sequence,
  obs_OccurranceDate,
  obs_MppOrEeID, 
  obs_ObservationType1 = IsNull(obs_ObservationType1,'UNK'), obs_ObservationType1_t = 'ObservationType1',
  obs_ObservationType2 = IsNull(obs_ObservationType2,'UNK'), obs_ObservationType2_t = 'ObservationType2',
  obs_Description,
  obs_EEObserver,  -- iff made by employee
  obs_ObserverName,  -- iff made by ouside person
  obs_ObserverAddress1,
  obs_ObserverAddress2,
  obs_ObserverCity,
  obs_ObserverCtynmstct,
  obs_ObserverState,
  obs_ObserverZip,
  obs_ObserverCountry,
  obs_ObserverHomePhone,
  obs_ObserverWorkPhone,
  obs_FollowUpRequired,
  obs_FollowUpDesc,
  obs_FollowUpCompleted,
  obs_FollowUpCompletedDate,
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
  emplicenseclass = IsNull(e1.emp_licenseclass,'UNK'),
  emphomephone = IsNull(e1.emp_Homephone,''),
  empWorkPhone = IsNull(emp_WorkPhone,''),
  empdateofbirth = e1.emp_dateofbirth,
  emphiredate = e1.emp_hiredate,
  empterminal = IsNull(e1.emp_terminal,'UNK'),empterminal_t = 'Terminal',
  EEObserverName = IsNull(IsNull((Select IsNull(ee_firstname + '','')+Isnull(ee_lastname,'')
    From employeeprofile Where ee_id = obs_EEObserver),
    (Select IsNull(mpp_firstname+' ','')+IsNull(mpp_lastname+' ','')+'(Driver)' From manpowerprofile
    Where mpp_Id = obs_EEObserver)),''),
  obs_string1 = isnull(obs_string1,''),
  obs_string2 = isnull(obs_string2,''),
  obs_string3 = isnull(obs_string3,''),
  obs_string4 = isnull(obs_string4,''),
  obs_string5 = isnull(obs_string5,''),
  obs_number1 = isnull(obs_number1,0),
  obs_number2 = isnull(obs_number2,0),
  obs_number3 = isnull(obs_number3,0),
  obs_number4 = isnull(obs_number4,0),
  obs_number5 = isnull(obs_number5,0),
  obs_ObservationType3 = IsNull(obs_ObservationType3,'UNK'),obs_ObservationType3_t = 'ObservationType3', 
  obs_ObservationType4 = IsNull(obs_ObservationType4,'UNK'),obs_ObservationType4_t = 'ObservationType4',
  obs_ObservationType5 = IsNull(obs_ObservationType5,'UNK'),obs_ObservationType5_t = 'ObservationType5',
  obs_ObservationType6 = IsNull(obs_ObservationType6,'UNK'),obs_ObservationType6_t = 'ObservationType6',
  obs_date1,
  obs_date2,
  obs_date3,
  obs_date4,
  obs_date5,
  obs_CKBox1  = isnull(obs_CKBox1,'N'),
  obs_CKBox2  = isnull(obs_CKBox2,'N'),
  obs_CKBox3  = isnull(obs_CKBox3,'N'),
  obs_CKBox4  = isnull(obs_CKBox4,'N'),
  obs_CKBox5  = isnull(obs_CKBox5,'N')
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
       emp_WorkPhone = '',
       emp_DateOfBirth = mpp_DateOfBirth,
       emp_HireDate = mpp_HireDate,
       emp_terminal = mpp_terminal,
       emp_ctynmstct = IsNull(cty_nmstct,'UNKNOWN') 
       From manpowerprofile left outer join city ON city.cty_code = manpowerprofile.mpp_city
       Where mpp_id in(Select distinct obs_MppOrEeID From Observation where srp_id = @srpid)
       --And city.cty_code =* mpp_city
       Union All
       Select
       emp_id = ee_id, 
       emp_name = IsNUll(ee_firstname+' ','')+IsNull(ee_MiddleInit+' ','')+IsNull(ee_lastname,''),
       emp_address1 = IsNull(ee_Address1,''),
       emp_Address2 = IsNull(ee_address2,''),
       emp_city = IsNull(ee_City,0),
       emp_CityName = IsNull(cty_Name,''),
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
       emp_terminal = ee_terminal,
       emp_ctynmstct = IsNull(ee_ctynmstct,'UNKNOWN')
 
       From employeeprofile LEFT OUTER JOIN city ON city.cty_code = employeeprofile.ee_city
       Where ee_id  in (Select distinct obs_MppOrEeID From Observation where srp_id = @srpid
       and ee_id <> 'UNKNOWN')
       --and city.cty_code =* ee_city
       ) e1 RIGHT OUTER JOIN Observation ON e1.emp_ID = Observation.obs_MppOrEeID
Where Observation.srp_id = @srpid
  --And e1.emp_ID =* obs_MppOrEeID
Order by obs_sequence
  
    

GO
GRANT EXECUTE ON  [dbo].[d_observation_sp] TO [public]
GO
