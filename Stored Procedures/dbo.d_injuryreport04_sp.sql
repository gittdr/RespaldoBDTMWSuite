SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
 Create Proc [dbo].[d_injuryreport04_sp] @srpid int   
As  
/*   
SR 21430 DPETE created 2/27/4
PTS 21787 changed inj_claimnumber to srp_claimnbr (claim moved to safety report) change nextappt to nextschedappt  
PTTS23452 DPETE bring back labelfile name for type of report 
 * 12/07/2010.01 - PTS53564 - vjh - new report format 04 based on 02
*/  

DECLARE @ReportName varchar(50)
Select @ReportName = name
From labelfile 
where labeldefinition = 'SafetyClassification'
and abbr = 'INJ'

Select @ReportName = IsNull(@reportName,'Injury')
  
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
     ,srp_estcost  
   ,srp_totalreserves  
   ,srp_totalpaidbycmp  
  ,srp_totalpaidbyins  
  ,srp_totalrecovered 
  ,srp_inscompany 
  ,srp_inscoaddress
  ,srp_srp_inscoctynmstct = case srp_inscoctynmstct When 'UNKNOWN' Then '' Else srp_inscoctynmstct End
  ,srp_inscozip
  ,srp_inscophone
  ,srp_inspolicynbr
  ,srp_claimnbr
  ,srp_reportedtoinsurance = IsNull(srp_reportedtoinsurance,'N')
  ,@ReportName   
  From safetyreport
		inner join injury on injury.srp_id = safetyreport.srp_id
		left outer join (Select   
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
						   Where ee_id  in (Select distinct srp_reportedby From safetyreport where srp_id = @srpid)
						   and ee_id <> 'UNKNOWN') AS e1 ON srp_reportedby = e1.emp_id
		left outer join (Select   
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
						   Where ee_id  in (Select distinct inj_MppOrEeID From injury where srp_id = @srpid)
						   and ee_id <> 'UNKNOWN') AS e2 ON inj_MppOrEeID = e2.emp_id
		left outer join city ON inj_city = city.cty_code
    
  Where safetyreport.srp_id = @srpid  
  
GO
GRANT EXECUTE ON  [dbo].[d_injuryreport04_sp] TO [public]
GO
