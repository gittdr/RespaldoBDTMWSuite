SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Proc [dbo].[d_injuryreport01_sp] @srpid int 
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
	SR 17782 DPETE created 12/29/03
	PTS 21787 changed inj_claimnumber to srp_claimnbr (claim moved to safety report) change nextappt to nextschedappt
 * 11/29/2007.01 ? PTS40462 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/


Select safetyreport.srp_ID,
  srp_number,
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
  step6 = IsNull((Select gi_string1 From generalinfo Where gi_name = 'SafetyReqStep6'),''),
  inj_sequence  , 
    inj_ReportedDate ,
    srp_claimNbr= IsNull(srp_claimnbr,''), 
    inj_Description = IsNull(inj_Description,''),  -- iff not related ot accident
    inj_Comment = IsNull(inj_comment,''),
    inj_HowOccurred = IsNull(inj_howoccurred,''),  -- iff not related to accident
    inj_DateOfFullRelease,
    inj_PersonIs ,  -- E for employee, O for other
    inj_MppOrEeID= IsNull(inj_mppOrEEID,'UNKNOWN'),  -- if injured person is employee
    inj_Name = IsNull(inj_name,''),  -- initalized from manpoer/emplyee file if is employee
    inj_Address1 = IsNull(inj_Address1,'') ,
    inj_Address2 = IsNull( inj_Address2,'') ,
    inj_City ,
    inj_Ctystzip = Case IsNull(inj_city ,0) When 0 Then '' Else IsNull(cty_name+', ','')+IsNull(inj_state,'')+'    '+IsNull(inj_zip,'') End,
    inj_State = IsNull(inj_state,''),
    inj_zip= IsNull(inj_zip,''),
    inj_Country  = IsNull(inj_Country,''),
    inj_HomePhone = IsNull(inj_HomePhone,''),
    inj_WorkPhone = IsNull(inj_WorkPhone,''),
    inj_LastDateWorked,
    inj_ExpectedReturn ,
    inj_ClaimInDoubt,
    inj_InjuryType1=IsNull(inj_InjuryType1,'UNK'),inj_InjuryType1_t = 'InjuryType1',  
    inj_InjuryType2=IsNull(inj_InjuryType2,'UNK'),inj_InjuryType2_t = 'InjuryType2', 
    inj_IsFatal ,  
    inj_TreatedAtScene,
    inj_AtSceneCaregiver,
    inj_TreatedAwayFromScene,
    inj_ReportedToInsurance,  --(Y,N)
    inj_InsCoReportDate ,
    inj_nextschedappt ,
    inj_maritalstatus,
    inj_gender ,
    inj_nbrdependents,
    inj_DateofBirth ,
    inj_ssn = IsNull(inj_ssn,''),
    inj_workstate = IsNull(inj_workstate,''),
    inj_occupation = IsNull(inj_occupation,'') ,
    empHiredate = e2.emp_hiredate,
    srp_onPremises = IsNull(srp_OnPremises,'N'),
    inj_medicalrestrictions = IsNull(inj_medicalrestrictions,'')  
  From 
   (Select 
       emp_id = mpp_id,
       emp_name = IsNUll(mpp_firstname+' ','')+IsNull(mpp_Middlename+' ','')+IsNull(mpp_lastname,''),
       emp_terminal = mpp_terminal
       From manpowerprofile 
       Where mpp_id in(Select distinct srp_reportedby From safetyreport where srp_id = @srpid)
       Union All
       Select
       emp_id = ee_id, 
       emp_name = IsNUll(ee_firstname+' ','')+IsNull(ee_MiddleInit+' ','')+IsNull(ee_lastname,''),
       emp_terminal = ee_terminal
       From employeeprofile 
       Where ee_id  in (Select distinct srp_reportedby From safetyreport where srp_id = @srpid))
    e1 RIGHT OUTER JOIN safetyreport ON e1.emp_id = safetyreport.srp_reportedby,
	  (Select 
       emp_id = mpp_id,
       emp_name = IsNUll(mpp_firstname+' ','')+IsNull(mpp_Middlename+' ','')+IsNull(mpp_lastname,''),
       emp_terminal = mpp_terminal,
       emp_hiredate = mpp_hiredate 
       From manpowerprofile 
       Where mpp_id in(Select distinct inj_MppOrEeID From injury where srp_id = @srpid)
       Union All
       Select
       emp_id = ee_id, 
       emp_name = IsNUll(ee_firstname+' ','')+IsNull(ee_MiddleInit+' ','')+IsNull(ee_lastname,''),
       emp_terminal = ee_terminal,
       emp_hiredate = ee_hiredate
       From employeeprofile 
       Where ee_id  in (Select distinct inj_MppOrEeID From injury where srp_id = @srpid))
    e2 RIGHT OUTER JOIN injury ON e2.emp_id = injury.inj_MppOrEeID
	   LEFT OUTER JOIN city ON city.cty_code = inj_city
  
  Where safetyreport.srp_id = @srpid
  And injury.srp_id = safetyreport.srp_id
--  and e1.emp_id =* srp_reportedby
--  and e2.emp_id =* inj_MppOrEeID 
--  and city.cty_code =* inj_city
 

GO
GRANT EXECUTE ON  [dbo].[d_injuryreport01_sp] TO [public]
GO
