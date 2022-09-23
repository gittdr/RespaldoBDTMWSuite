SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
Create Proc [dbo].[d_accidentreport02_sp] @srpid int   
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
   PTS21430 DPETE created 2/13/4  
   PTTS23452 DPETE bring back labelfile name for type of report 
 * 11/28/2007.01 ? PTS40462 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE @ReportName varchar(50)
Select @ReportName = name
From labelfile 
where labeldefinition = 'SafetyClassification'
and abbr = 'ACC'

Select @ReportName = IsNull(@reportName,'Accident')
  
Select safetyreport.srp_ID,  
  srp_number,  
  srp_reporteddate,  
  srp_Reportedby,  
  reportedbyname = IsNull(e1.emp_name,''),  
  srp_description = IsNull(srp_description,''),  
  srp_ClassificationName = (Select name From labelfile Where labeldefinition = 'SafetyClassification' and abbr =  IsNull(srp_Classification,'UNK')),  
  injcount = IsNull(acd_nbrofinjuries,0),  
  ovdcount = (Select count(*) From othervehicledamage Where othervehicledamage.srp_id = @srpid),  
  opdcount = (Select count(*) From propertydamage Where propertydamage.srp_id = @srpid),  
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
  acd_description = IsNull(acd_description,''),  
  acd_cvdamage = IsNull(acd_cvdamage,'N'),  
  acd_ovdamaged = IsNull(acd_ovdamaged,'N'),  
  acd_opdamaged = IsNull(acd_opdamaged,'N'),  
  acdInjuries = Case IsNull(acd_nbrofinjuries,0) When 0 Then 'N' Else 'Y' End,  
  acdfatalities = Case IsNull(acd_nbroffatalities,0) When 0 Then 'N' Else 'Y' End,  
  acd_nbrofinjuries = IsNull(acd_nbrofinjuries,0),  
  acd_nbroffatalities = IsNull(acd_nbroffatalities,0),  
  acd_vehicletowed = IsNull(acd_vehicletowed,'N'),  
  acd_alcoholtestdone = IsNull(acd_alcoholtestdone,'N'),  
  acd_drugtestdone = IsNull(acd_drugtestdone,'N'),  
  acd_lawenfdeptaddress = IsNull(acd_lawenfdeptaddress,''),  
  acd_lawenfdeptname = IsNull(acd_lawenfdeptname,''),  
  acd_lawenfofficer = IsNull(acd_lawenfofficer,''),  
  acd_lawenfofficerbadge = IsNull(acd_lawenfofficerbadge,''),  
  acd_policereportnumber = IsNull(acd_policereportnumber,''),  
  acd_Tractor = Case IsNull(acd_tractor,'UNKNOWN') When 'UNKNOWN' Then '' Else acd_tractor End,  
  trc_year = IsNull(trc_year,''),  
  trc_make = IsNull(trc_make,''),  
  trc_model = IsNull(trc_model,''),  
  trc_serial = IsNull(trc_serial,''),  
  trc_licnum = IsNull(trc_licnum,''),  
  trc_LicState = IsNull(trc_LicState,''),  
  trcownername = case IsNull(Rtrim(trc_owner),'UNKNOWN') When 'UNKNOWN' Then '' When ''  Then '' Else  
     IsNull(pttrc.pto_Fname+' ','')+IsNull(pttrc.pto_lname,'') + IsNull(' of '+ pttrc.pto_companyname,'') End,  
  trcowneraddress = case IsNull(trc_owner,'UNKNOWN') When 'UNKNOWN' Then '' Else  
    IsNull(pttrc.pto_address1,'') End,  
  trcownercitystatezip = case IsNull(trc_owner,'UNKNOWN') When 'UNKNOWN' Then '' Else  
     Case pttrc.pto_city When 0 Then '' Else   
     (Select IsNull(cty_name,'')+', '+IsNull(cty_state,'') From city c1 Where cty_code = pttrc.pto_city)   
        + '    ' +IsNull(pttrc.pto_zip,'') End End,  
  trcownerphone = case IsNull(trc_owner,'UNKNOWN') When 'UNKNOWN' Then '' Else  
    IsNull(pttrc.pto_phone1,'') End,  
  acd_trcdamage = IsNull(acd_trcdamage,''),  
  acd_trailer1 = case IsNull(acd_trailer1,'UNKNOWN') When 'UNKNOWN' then '' Else acd_trailer1 End,  
  trl1_year = IsNull(tr1.trl_year,''),  
  trl1_make = IsNull(tr1.trl_make,''),  
  trl1_Model = IsNull(tr1.trl_model,''),  
  trl1_serial = IsNull(tr1.trl_serial,''),  
  trl1_licnum = IsNull(tr1.trl_licnum,''),  
  trl1_licState = isNull(tr1.trl_licState,''),  
  trl1ownername = Case isNull(Rtrim(tr1.trl_owner),'UNKNOWN') When 'UNKNOWN' Then '' When '' Then ''  Else  
     IsNull(pttr1.pto_Fname+' ','')+IsNull(pttr1.pto_lname,'')+ IsNull(' of '+ pttr1.pto_companyname,'') End,  
  trl1owneraddress = Case IsNull(tr1.trl_Owner,'UNKNOWN') When 'UNKNOWN' Then '' Else  
  IsNull(pttr1.pto_address1,'') End,  
  trl1ownercitystatezip = Case IsNull(tr1.trl_Owner,'UNKNOWN') When 'UNKNOWN' Then '' Else  
     Case pttr1.pto_city When 0 Then '' Else   
     (Select IsNull(cty_name,'')+', '+IsNull(cty_state,'') From city c1 Where c1.cty_code = pttr1.pto_city)   
     +'    '+ IsNull(pttr1.pto_zip,'') End End,  
  trl1ownerphone = IsNull(pttr1.pto_phone1,''),  
  acd_trl1damage= IsNull(acd_trl1damage,''),  
  acd_driver1 = Case IsNull(acd_driver1,'UNKNOWN') When 'UNKNOWN' Then '' Else acd_Driver1 End,  
  drv1name = IsNull(mpp1.mpp_firstname,'')+ ' '+IsNull(mpp1.mpp_lastname,''),  
  drv1homephone = IsNull(mpp1.mpp_homephone,''),  
  drv1address = IsNull(mpp1.mpp_address1,''),  
  drv1citystatezip = Case IsNull(mpp1.mpp_city,0) When 0 Then '' Else  
     (Select IsNull(cty_name,'')+', '+IsNull(cty_state,'') From city c2 Where c2.cty_code = mpp1.mpp_city) + IsNull(mpp1.mpp_zip,'') End,  
  drv1license = IsNull(mpp1.mpp_licenseNumber,''),  
  drv1licensestate = IsNull(mpp1.mpp_LicenseState,''),  
  drv1terminalname = (Select name From labelfile l2 Where l2.labeldefinition = 'Terminal' and l2.abbr = isNull(mpp1.mpp_terminal,'UNK')),  
  drv2name = IsNull(mpp2.mpp_firstname,'')+ ' '+IsNull(mpp2.mpp_lastname,''),  
  drv2homephone = IsNull(mpp2.mpp_homephone,''),  
  drv2address = IsNull(mpp2.mpp_address1,''),  
  drv2citystatezip = Case IsNull(mpp2.mpp_city,0) When 0 Then '' Else  
     (Select IsNull(cty_name,'')+', '+IsNull(cty_state,'') From city c3 Where c3.cty_code = mpp2.mpp_city) + IsNull(mpp2.mpp_zip,'') End,  
  drv2license = IsNull(mpp2.mpp_licenseNumber,''),  
  drv2licensestate = IsNull(mpp2.mpp_LicenseState,''),  
  drv2terminalname = (Select name From labelfile l3 Where l3.labeldefinition = 'Terminal' and l3.abbr = isNull(mpp2.mpp_terminal,'UNK')),  
  acd_DOTRecordable = IsNull(acd_DOTRecordable,'N'),  
  acd_alcoholtestresult = IsNull(acd_alcoholtestresult,'N'),  
  acd_drugtestresult = IsNull(acd_Drugtestresult,'N'),  
  treatedatscene = Case When   
     (Select count(*) From Injury Where srp_ID = @srpid and inj_treatedatScene = 'Y')> 0 Then 'Y'  
      Else 'N' End,  
  treatedawayfromscene = Case When   
     (Select count(*) From Injury Where srp_ID = @srpid and inj_treatedawayfromscene = 'Y')> 0 Then 'Y'  
      Else 'N' End,  
  acd_LawEnfDeptPhone = IsNull(acd_LawEnfDeptPhone,'') ,  
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
  srpsafetytype1name = IsNull(lb1.name,''),  
  acdlawenfdeptcitystatezip = IsNull(cty_name+', ','')+IsNull(acd_lawenfdeptState,'')+IsNull('    '+acd_LawEnfDeptZip,'')  
 ,srp_inscompany = IsNull(srp_inscompany,'')  
 ,srp_inscoaddress = IsNull(srp_inscoaddress,'')  
 ,srp_inscoctynmstct = IsNull(srp_inscoctynmstct,'')  
 ,srp_inscozip = IsNull(srp_inscozip,'')  
 ,srp_inscophone = isNull(srp_inscophone,'')  
 ,srp_reportedtoinsurance = IsNull(srp_reportedtoinsurance,'N')  
 ,srp_inscoreportdate   
 ,srp_claimnbr= isNull(srp_claimnbr,'')  
 ,acd_ticketissued = IsNull(acd_ticketissued,'N')  
 ,acd_estspeed = IsNull(acd_estspeed,0)  
 ,acd_trafficviolation = IsNull(acd_trafficviolation,'UNK'),acd_trafficviolation_t = 'TrafficViolation' 
 ,acd_driveratwheet = IsNull(acd_driveratwheel,1)
 ,acd_driver2 = Isnull(acd_driver2,'UNKNOWN') 
 ,srp_estcost
 ,srp_totalreserves
 ,srp_totalpaidbycmp
 ,srp_totalpaidbyins
 ,srp_totalrecovered
 ,srp_inspolicynbr = IsNull(srp_inspolicynbr,'')
,@ReportName
,srp_cargodamagecost = IsNull(srp_cargodamagecost,0)
  From tractorprofile  
   , trailerprofile tr1  
   , manpowerprofile mpp1  
   ,manpowerprofile mpp2  
   ,payto pttrc  
 , payto pttr1  
  ,(Select   
       emp_id = mpp_id,  
       emp_name = IsNUll(mpp_firstname+' ','')+IsNull(mpp_Middlename+' ','')+IsNull(mpp_lastname,''),  
       emp_terminal = mpp_terminal   
       From manpowerprofile   
       Where mpp_id in(Select distinct srp_reportedby From safetyreport where srp_id = @srpid and srp_reportedby <> 'UNKNOWN')  
       Union All  
       Select  
       emp_id = ee_id,   
       emp_name = IsNUll(ee_firstname+' ','')+IsNull(ee_MiddleInit+' ','')+IsNull(ee_lastname,''),  
       emp_terminal = ee_terminal  
       From employeeprofile   
       Where ee_id  in (Select distinct srp_reportedby From safetyreport where srp_id = @srpid and srp_reportedby <> 'UNKNOWN'))  
    e1 RIGHT OUTER JOIN safetyreport ON e1.emp_id = safetyreport.srp_reportedby,  
    labelfile lb1,  
    city RIGHT OUTER JOIN accident ON city.cty_code = accident.acd_LawEnfDeptCity
    
  Where safetyreport.srp_id = @srpid  
  And accident.srp_id = safetyreport.srp_id  
  And tractorprofile.trc_number = IsNull(acd_tractor,'UNKNOWN')  
  And tr1.trl_id = IsNull(acd_Trailer1,'UNKNOWN')  
  and mpp1.mpp_id = IsNull(acd_Driver1,'UNKNOWN')  
  And mpp2.mpp_id = IsNull(acd_Driver2,'UNKNOWN')  
  and pttrc.pto_id = (Case IsNull(Rtrim(tractorprofile.trc_owner),'UNKNOWN') When '' Then 'UNKNOWN' Else IsNull(tractorprofile.trc_owner,'UNKNOWN') End )  
  and pttr1.pto_id = (Case IsNull(Rtrim(tr1.trl_owner),'UNKNOWN') When '' Then 'UNKNOWN' Else IsNull(tr1.trl_owner,'UNKNOWN') End )  
  and lb1.labeldefinition = 'SafetyType1'   
  and lb1.abbr = IsNull(srp_Safetytype1,'UNK')  
GO
GRANT EXECUTE ON  [dbo].[d_accidentreport02_sp] TO [public]
GO
