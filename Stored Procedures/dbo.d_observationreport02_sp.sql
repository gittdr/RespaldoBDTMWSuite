SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Proc [dbo].[d_observationreport02_sp] @srpid int
As
/* 
SR 21430 DPETE created 2/27/4 
PTTS23452 DPETE bring back labelfile name for type of report 
 * 11/30/2007.01 ? PTS40463 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
*/  

DECLARE @ReportName varchar(50)
Select @ReportName = name
From labelfile 
where labeldefinition = 'SafetyClassification'
and abbr = 'OBS'

Select @ReportName = IsNull(@reportName,'Observation')

Select safetyreport.srp_number,
  srp_reporteddate,
  srp_Reportedby,
  reportedbyname = IsNull(e1.emp_name,''),
  srp_description = IsNull(srp_description,''),
  srp_ClassificationName = (Select name From labelfile Where labeldefinition = 'SafetyClassification' and abbr =  IsNull(srp_Classification,'UNK')),
  srp_Eventdate,
  srp_terminal,
  terminalname = (Select name From Labelfile Where abbr = IsNull(srp_terminal,'UNK') and labeldefinition = 'RevType' + 
    IsNull((Select gi_string1 From generalinfo Where gi_name = 'terminalRevType'),'1')),
  srp_EventLoc = IsNull(srp_EventLoc,''),
  srp_EventAddress1 = IsNull(srp_EventAddress1,''),
  srp_EventAddress2 = IsNull(srp_EventAddress2,''),
  srp_Eventcity = IsNull(srp_EventCity,0),
  srp_EventCtynmstct = IsNull(srp_EventCtynmstct,'UNKNOWN'),
  srp_EventState = IsNull(srp_EventState,''),
  srp_EventZip = IsNull(srp_eventZip,''),
  srp_EventCountry = IsNull(srp_EventCountry,''),
  srp_Req1Complete = IsNull(srp_Req1Complete,'N'),
  srp_Req2Complete = IsNull(srp_Req2Complete,'N'),
  srp_Req3Complete = IsNull(srp_Req3Complete,'N'),
  srp_Req4Complete = IsNull(srp_Req4Complete,'N'),
  srp_Req5Complete = IsNull(srp_Req5Complete,'N'),
  srp_Req6Complete = IsNull(srp_Req6Complete,'N'),
  srp_Req1DtDone,
  srp_Req2DtDone,
  srp_Req3DtDone,
  srp_Req4DtDone,
  srp_Req5DtDone,
  srp_Req6DtDone,
  step1 = IsNull((Select gi_string1 From generalinfo Where gi_name = 'SafetyReqStep1'),''),
  step2 = IsNull((Select gi_string1 From generalinfo Where gi_name = 'SafetyReqStep2'),''),
  step3 = IsNull((Select gi_string1 From generalinfo Where gi_name = 'SafetyReqStep3'),''),
  step4 = IsNull((Select gi_string1 From generalinfo Where gi_name = 'SafetyReqStep4'),''),
  step5 = IsNull((Select gi_string1 From generalinfo Where gi_name = 'SafetyReqStep5'),''),
  step6 = IsNull((Select gi_string1 From generalinfo Where gi_name = 'SafetyReqStep6'),'')
  ,srp_inscompany = IsNull(srp_inscompany,'')
 ,srp_inscoaddress = IsNull(srp_inscoaddress,'')
 ,srp_inscoctynmstct = IsNull(srp_inscoctynmstct,'')
 ,srp_inscozip = IsNull(srp_inscozip,'')
 ,srp_inscophone = isNull(srp_inscophone,'')
 ,srp_reportedtoinsurance = IsNull(srp_reportedtoinsurance,'N')
 ,srp_inscoreportdate 
 ,srp_claimnbr= isNull(srp_claimnbr,'')
  ,obs_ID,
  obs_sequence,
  obs_OccurranceDate,
  obs_MppOrEeID, 
  obs_ObservationType1, obs_ObservationType1_t = 'ObservationType1',
  obs_ObservationType2, obs_ObservationType2_t = 'ObservationType2',
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
    Where mpp_Id = obs_EEObserver)),'')
  ,empsupervisor = Case emp_type  When 'E' Then IsNull(emp_supervisor,'UNKNOWN')else IsNull(emp_teamleader,'UNK') End
  ,empterminalname = IsNull(emp_terminalname,'')
  ,Supervisorname = Case emp_type When 'E' Then 
     (Select IsNUll(ee_firstname+' ','')+IsNull(ee_MiddleInit+' ','')+IsNull(ee_lastname,'')
       From employeeprofile ee2 Where ee2.ee_id = ee_SupervisorID)
     Else IsNull(emp_teamleader,'') End
  ,emp_occupation
  ,@ReportName
From Safetyreport,
  (Select emp_type = 'D',
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
       emp_ctynmstct = IsNull(cty_nmstct,'UNKNOWN'),
       emp_supervisor = '',
       emp_teamleader = IsNull(mpp_teamleader,'UNK'),
       emp_terminalname = IsNull(lb.name,''),
       emp_occupation = 'Driver'
       From manpowerprofile LEFT OUTER JOIN city ON city.cty_code = manpowerprofile.mpp_city,
			labelfile lb
       Where mpp_id in(Select distinct obs_MppOrEeID From Observation where srp_id = @srpid)
       --And city.cty_code =* mpp_city
       And lb.labeldefinition = 'terminal' and lb.abbr = mpp_terminal
       Union All
       Select emp_type = 'E',
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
       emp_ctynmstct = IsNull(ee_ctynmstct,'UNKNOWN'),
       emp_Supervisor = IsNull(ee_SupervisorID,'UNKNOWN') ,
       emp_teamleader = '',
       emp_terminalname = IsNull(lb.name,''),
       emp_occupation = IsNull(ee_occupation,'') 
       From employeeprofile LEFT OUTER JOIN city ON city.cty_code = employeeprofile.ee_city,
			labelfile lb
       Where ee_id  in (Select distinct obs_MppOrEeID From Observation where srp_id = @srpid)
       and ee_id <> 'UNKNOWN'
	   --and city.cty_code =* ee_city
       and lb.labeldefinition = 'Terminal' and lb.abbr = ee_terminal)
    e1 RIGHT OUTER JOIN Observation ON e1.emp_ID = Observation.obs_MppOrEeID
Where Safetyreport.srp_id = @srpid
  And Observation.srp_id = Safetyreport.srp_id
  --And e1.emp_ID =* obs_MppOrEeID
Order by obs_sequence
  
    

GO
GRANT EXECUTE ON  [dbo].[d_observationreport02_sp] TO [public]
GO
